import json
import logging
import re
from typing import List, Optional

from app.core.config import settings
from app.schemas.pricing import ComparableProduct, PriceSuggestionRequest, PriceSuggestionResponse

logger = logging.getLogger("hastkala.ai.pricing")


def _sanitize_price(val) -> Optional[int]:
    if val is None:
        return None
    if isinstance(val, (int, float)):
        return int(val) if val > 0 else None
    if isinstance(val, str):
        cleaned = re.sub(r"[^\d]", "", val)
        if cleaned:
            parsed = int(cleaned)
            return parsed if parsed > 0 else None
    return None


def _round_to_rupee(amount: float, step: int = 50) -> int:
    """Rounds to human-friendly clean price steps (e.g. multiples of 50)."""
    val = round(amount / step) * step
    return max(step, int(val))


def _calculate_pricing_logic(
    artisan_expected: int,
    comparables: List[ComparableProduct],
    craft: Optional[str] = None,
    material: Optional[str] = None,
    product_name: Optional[str] = None,
) -> dict:
    """Pure Python calculation logic to determine market range,
    recommended range, and suggested price from artisan input and evidence.
    """
    valid_prices = [p.price for p in comparables if p.price > 0]

    # Outlier removal: filter out unrealistic prices
    filtered_prices = []
    for p in valid_prices:
        # Avoid extreme outliers (e.g. mass-manufactured plastic trinket or luxury multi-item bundle)
        if 0.25 * artisan_expected <= p <= 5.0 * artisan_expected:
            filtered_prices.append(p)
        elif not filtered_prices and p > 0:
            filtered_prices.append(p)

    if not filtered_prices:
        # Weak or missing market evidence fallback
        m_min = _round_to_rupee(artisan_expected * 0.8)
        m_max = _round_to_rupee(artisan_expected * 1.25)
        rec_min = _round_to_rupee(artisan_expected * 0.9)
        rec_max = _round_to_rupee(artisan_expected * 1.15)
        suggested = artisan_expected

        reason = (
            "We couldn't find enough similar products for a reliable estimate. "
            "You have full control over your final selling price."
        )
        return {
            "market_min": m_min,
            "market_max": m_max,
            "recommended_min": rec_min,
            "recommended_max": rec_max,
            "suggested_price": suggested,
            "comparables_found": 0,
            "reason": reason,
        }

    # Statistical computation on genuine comparables
    m_min = min(filtered_prices)
    m_max = max(filtered_prices)
    avg_price = sum(filtered_prices) / len(filtered_prices)

    if artisan_expected < avg_price:
        # Artisan may be under-valuing their handcrafted skill
        # Suggest a competitive price between expected and market average
        suggested = _round_to_rupee(artisan_expected * 0.4 + avg_price * 0.6)
        rec_min = max(artisan_expected, _round_to_rupee(suggested * 0.9))
        rec_max = max(suggested, _round_to_rupee(suggested * 1.15))
    else:
        # Artisan has high expectation (premium material, high effort, or heritage)
        # We respect their price while providing a viable bracket
        suggested = artisan_expected
        rec_min = _round_to_rupee(min(artisan_expected * 0.95, avg_price))
        rec_max = _round_to_rupee(artisan_expected * 1.1)

    # Ensure logical boundaries
    market_min = min(m_min, artisan_expected, rec_min)
    market_max = max(m_max, artisan_expected, rec_max)
    recommended_min = min(rec_min, suggested)
    recommended_max = max(rec_max, suggested)

    item_desc = f"{craft or ''} {material or ''} {product_name or 'handcrafted item'}".strip()
    reason = (
        f"Based on {len(filtered_prices)} comparable handcrafted listings found online. "
        f"Considers {item_desc or 'product craftsmanship'}, material quality, and your expected price."
    )

    return {
        "market_min": market_min,
        "market_max": market_max,
        "recommended_min": recommended_min,
        "recommended_max": recommended_max,
        "suggested_price": suggested,
        "comparables_found": len(filtered_prices),
        "reason": reason,
    }


def _query_groq_comparables(req: PriceSuggestionRequest) -> List[ComparableProduct]:
    """Uses Groq to find genuine online pricing evidence for comparable Indian handicrafts."""
    if not settings.GROQ_API_KEY:
        logger.warning("GROQ_API_KEY is not configured.")
        return []

    try:
        from groq import Groq

        client = Groq(api_key=settings.GROQ_API_KEY)
    except Exception as e:
        logger.error(f"Failed to initialize Groq client: {e}")
        return []

    # Build concise, focused query to avoid token limits
    query_parts = []
    if req.product_name:
        query_parts.append(req.product_name)
    if req.craft:
        query_parts.append(f"craft: {req.craft}")
    if req.material:
        query_parts.append(f"material: {req.material}")
    if req.size:
        query_parts.append(f"size: {req.size}")
    if req.location:
        query_parts.append(f"origin: {req.location}")

    item_summary = ", ".join(query_parts) or "Handmade Indian handicraft product"

    prompt = (
        f"Find 3 genuine comparable handmade products sold online in India for: {item_summary}. "
        f"Expected price baseline: INR {req.artisan_expected_price}. "
        "Search Indian craft stores like Jaypore, Itokri, Okhai, Craftsvilla, Amazon Karigar. "
        "Output ONLY a JSON array with title, price (integer in INR), and source platform. "
        "Do not compare with factory or plastic mass products. Format: "
        '[{"title": "Product Title", "price": 850, "source": "Store Name"}]'
    )

    candidate_models = ["groq/compound-mini", "openai/gpt-oss-20b"]

    for model_name in candidate_models:
        try:
            logger.info(f"Querying Groq model {model_name} for price research...")
            chat = client.chat.completions.create(
                model=model_name,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=400,
                timeout=8.0,
            )
            raw_content = chat.choices[0].message.content or ""
            logger.info(f"Groq {model_name} responded ({len(raw_content)} chars)")

            # Parse JSON
            raw_content = raw_content.strip()
            match = re.search(r"\[\s*\{.*\}\s*\]", raw_content, re.DOTALL)
            json_str = match.group(0) if match else raw_content

            parsed_list = json.loads(json_str)
            if isinstance(parsed_list, list) and len(parsed_list) > 0:
                comparables = []
                for item in parsed_list:
                    if isinstance(item, dict):
                        price = _sanitize_price(item.get("price"))
                        title = item.get("title") or item.get("name") or "Handcrafted Item"
                        source = item.get("source") or item.get("platform") or "Indian Craft Marketplace"
                        url = item.get("url") or None
                        if price is not None and price > 0:
                            comparables.append(
                                ComparableProduct(
                                    title=str(title)[:100],
                                    price=price,
                                    source=str(source)[:60],
                                    url=url,
                                )
                            )
                if comparables:
                    return comparables
        except Exception as e:
            logger.warning(f"Groq query with {model_name} failed: {e}")
            continue

    return []


def suggest_price(req: PriceSuggestionRequest) -> PriceSuggestionResponse:
    """Main Price Assistant workflow:
    1. Gather market comparable evidence via Groq
    2. Execute deterministic Python pricing calculation
    3. Return transparent suggested ranges with evidence
    """
    logger.info(f"Price suggestion requested for expected_price={req.artisan_expected_price}")

    # Step 1: Research comparable products
    comparables = _query_groq_comparables(req)

    # Step 2: Python pricing logic
    calc = _calculate_pricing_logic(
        artisan_expected=req.artisan_expected_price,
        comparables=comparables,
        craft=req.craft,
        material=req.material,
        product_name=req.product_name,
    )

    return PriceSuggestionResponse(
        success=True,
        artisan_expected_price=req.artisan_expected_price,
        market_min=calc["market_min"],
        market_max=calc["market_max"],
        recommended_min=calc["recommended_min"],
        recommended_max=calc["recommended_max"],
        suggested_price=calc["suggested_price"],
        comparables_found=calc["comparables_found"],
        reason=calc["reason"],
        sources=comparables if calc["comparables_found"] > 0 else [],
    )
