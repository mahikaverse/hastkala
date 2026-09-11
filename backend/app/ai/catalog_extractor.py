import json
import logging
import re
from typing import Optional

import httpx

from app.core.config import settings
from app.schemas.catalog import ProductDetails

logger = logging.getLogger("hastkala.ai.extractor")

_client: Optional[httpx.Client] = None

EXTRACTION_PROMPT = """You are a product data extractor for Indian handicraft artisans. Extract facts explicitly stated in the transcript. Output valid JSON only.
Transcript:
{transcript}

JSON structure:
{{
  "product_name": null,
  "category": null,
  "material": null,
  "craft": null,
  "color": null,
  "size": null,
  "weight": null,
  "quantity": null,
  "making_time": null,
  "making_process": null,
  "location": null,
  "price": null,
  "craft_story": null
}}"""


def _get_client() -> httpx.Client:
    global _client
    if _client is None or _client.is_closed:
        _client = httpx.Client(
            base_url=settings.OLLAMA_BASE_URL,
            timeout=httpx.Timeout(3.0, connect=1.0),
        )
        logger.info(f"Ollama client created: {settings.OLLAMA_BASE_URL}")
    return _client


def check_ollama_health() -> dict:
    try:
        client = _get_client()
        resp = client.get("/api/tags", timeout=httpx.Timeout(2.0, connect=1.0))
        resp.raise_for_status()
        models = resp.json().get("models", [])
        model_names = [m.get("name", "") for m in models]
        return {"available": True, "models": model_names}
    except Exception as e:
        logger.warning(f"Ollama health check failed: {e}")
        return {"available": False, "models": [], "error": str(e)}


def _safe_parse_json(raw: str) -> Optional[dict]:
    raw = raw.strip()
    if raw.startswith("```"):
        lines = raw.split("\n")
        lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        raw = "\n".join(lines).strip()

    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass

    match = re.search(r"\{.*\}", raw, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(0))
        except json.JSONDecodeError:
            pass

    return None


def extract_fast(transcript: str) -> ProductDetails:
    """Ultra-fast regex and NLP keyword extractor for Indian handicrafts.
    Runs in < 2ms without any network or GPU dependency.
    """
    t = transcript.strip()
    if not t:
        return ProductDetails()

    lower = t.lower()

    # 1. Price
    price = None
    price_patterns = [
        r'(?:price|keemat|kimat|rate|cost|lagat|bhav)\s*(?:is|hai|h|:)?\s*₹?\s*(\d[\d,]*)',
        r'₹\s*(\d[\d,]*)',
        r'(\d[\d,]*)\s*(?:rupees|rupaye|rupee|rs\.?|r[ps]\b)',
        r'(?:bika|bechenge|denge|milega|rakha|rakhi)\s*(\d[\d,]*)\s*(?:mein|me|ka|ki)',
    ]
    for p in price_patterns:
        m = re.search(p, lower)
        if m:
            price = m.group(1).replace(',', '')
            break

    # 2. Material
    materials = [
        ('Terracotta', ['terracotta', 'teracota', 'pakki mitti', 'baked clay']),
        ('Clay', ['clay', 'mitti', 'chikni mitti', 'kali mitti', 'lal mitti']),
        ('Bamboo', ['bamboo', 'baans', 'bans', 'cane']),
        ('Teak Wood', ['teak', 'sagwan', 'saagwan']),
        ('Sheesham Wood', ['sheesham', 'shisham', 'rosewood']),
        ('Wood', ['wood', 'wooden', 'lakdi', 'lakadi', 'kashth']),
        ('Silk', ['silk', 'reshmi', 'resham', 'tussar', 'muga', 'chanderi', 'banarasi silk']),
        ('Cotton', ['cotton', 'sooti', 'suti', 'khadi', 'malmal']),
        ('Brass', ['brass', 'peetal', 'pital']),
        ('Copper', ['copper', 'tamba', 'taamba']),
        ('Bronze', ['bronze', 'kansa', 'kaansa']),
        ('Marble', ['marble', 'sangmarmar', 'patthar', 'stone']),
        ('Jute', ['jute', 'patson', 'san']),
        ('Leather', ['leather', 'chamda', 'chamde']),
        ('Ceramic', ['ceramic', 'porcelain', 'chini mitti']),
        ('Glass', ['glass', 'kaanch', 'kanch']),
        ('Metal', ['metal', 'loha', 'iron']),
        ('Wool', ['wool', 'oon', 'pashmina', 'cashmere']),
    ]
    material = None
    for mat_name, keywords in materials:
        for kw in keywords:
            if re.search(r'\b' + re.escape(kw) + r'\b', lower):
                material = mat_name
                break
        if material:
            break

    # 3. Category
    categories = [
        ('Pottery & Ceramics', ['pottery', 'matka', 'pot', 'diya', 'vase', 'kulhad', 'ceramic', 'clay', 'terracotta', 'mitti', 'cup', 'kullhad']),
        ('Woodwork', ['wood', 'wooden', 'furniture', 'carving', 'toy', 'sheesham', 'lakdi', 'box', 'jharokha', 'mandir']),
        ('Textiles & Handloom', ['saree', 'dupatta', 'kurta', 'shawl', 'fabric', 'cloth', 'weaving', 'handloom', 'chikankari', 'cotton', 'silk', 'embroidery', 'stole', 'bedsheet', 'chiffon']),
        ('Jewelry & Accessories', ['jewelry', 'jewellery', 'necklace', 'earring', 'bangle', 'ring', 'pendant', 'jhumka', 'haar', 'churi', 'kangan', 'payal']),
        ('Metal Craft', ['metal', 'brass', 'copper', 'bronze', 'bell', 'dhokra', 'bidri', 'peetal', 'diya', 'lamp']),
        ('Paintings & Art', ['painting', 'art', 'madhubani', 'warli', 'pattachitra', 'canvas', 'chitra', 'portrait', 'tanjore']),
        ('Bamboo & Cane', ['bamboo', 'cane', 'wicker', 'tokri', 'basket', 'baans', 'mat']),
        ('Leather Craft', ['leather', 'bag', 'wallet', 'jooti', 'mojari', 'chamda', 'belt']),
        ('Stone Craft', ['stone', 'marble', 'sculpture', 'murti', 'idol', 'carved stone']),
    ]
    category = None
    for cat_name, keywords in categories:
        for kw in keywords:
            if re.search(r'\b' + re.escape(kw) + r'\b', lower):
                category = cat_name
                break
        if category:
            break

    # 4. Craft Technique
    crafts = [
        ('Blue Pottery', ['blue pottery']),
        ('Terracotta Craft', ['terracotta', 'teracota', 'pakki mitti']),
        ('Hand Carving', ['hand carving', 'carved', 'nakkashi', 'carving', 'tarasha']),
        ('Hand Painted', ['hand painted', 'painted', 'rangoli', 'paint kiya', 'chitrakala']),
        ('Handloom Weaving', ['handloom', 'weaving', 'bunkar', 'bunai', 'hath kargha', 'buna hua']),
        ('Chikankari', ['chikankari', 'chikan']),
        ('Block Printing', ['block print', 'ajrakh', 'dabu', 'bagru', 'chhappai', 'thappa']),
        ('Madhubani Painting', ['madhubani', 'mithila']),
        ('Warli Art', ['warli']),
        ('Pattachitra', ['pattachitra', 'patachitra']),
        ('Dhokra Art', ['dhokra', 'dokra']),
        ('Bidriware', ['bidri']),
        ('Zardozi Embroidery', ['zardozi', 'zari', 'gota patti', 'aari']),
        ('Wheel Pottery', ['wheel', 'chaak', 'chaak par', 'mitti ka kaam']),
        ('Cane Weaving', ['cane weaving', 'tokri bunai', 'baans bunai']),
        ('Handcrafted', ['handcrafted', 'handmade', 'haath se', 'hath se', 'hastshilp', 'hastkala']),
    ]
    craft = None
    for craft_name, keywords in crafts:
        for kw in keywords:
            if re.search(r'\b' + re.escape(kw) + r'\b', lower):
                craft = craft_name
                break
        if craft:
            break

    # 5. Color
    colors = [
        ('Blue', ['blue', 'neela', 'neeli', 'aasmaani']),
        ('Red', ['red', 'lal', 'laal']),
        ('Green', ['green', 'hara', 'hari']),
        ('Yellow', ['yellow', 'peela', 'peeli']),
        ('Black', ['black', 'kala', 'kali']),
        ('White', ['white', 'safed', 'chitta']),
        ('Gold', ['gold', 'golden', 'sunehra', 'sunhara', 'zari']),
        ('Silver', ['silver', 'chandi', 'rupehla']),
        ('Brown', ['brown', 'bhoora', 'bhoori']),
        ('Pink', ['pink', 'gulabi']),
        ('Orange', ['orange', 'narangi', 'kesariya']),
        ('Multicolor', ['multicolor', 'colourful', 'rang biranga', 'multi-color', 'rangin']),
    ]
    color = None
    for col_name, keywords in colors:
        for kw in keywords:
            if re.search(r'\b' + re.escape(kw) + r'\b', lower):
                color = col_name
                break
        if color:
            break

    # 6. Size
    size = None
    size_match = re.search(r'(\d+(?:\.\d+)?\s*(?:inch|inches|cm|centimeters?|feet|foot|meter|in|ft)\b)', lower)
    if size_match:
        size = size_match.group(1).strip()
    else:
        for s_name, kws in [
            ('Small', ['small', 'chhota', 'chhoti']),
            ('Medium', ['medium', 'madhyam', 'beech ka']),
            ('Large', ['large', 'bada', 'badi', 'big']),
            ('XL', ['xl', 'extra large']),
        ]:
            for kw in kws:
                if re.search(r'\b' + re.escape(kw) + r'\b', lower):
                    size = s_name
                    break
            if size:
                break

    # 7. Weight
    weight = None
    weight_match = re.search(r'(\d+(?:\.\d+)?\s*(?:gram|grams|gm|gms|g|kg|kilogram|kilo)\b)', lower)
    if weight_match:
        weight = weight_match.group(1).strip()
    elif 'aadha kilo' in lower or 'aadha kg' in lower:
        weight = '500 g'
    elif 'ek kilo' in lower or '1 kilo' in lower:
        weight = '1 kg'

    # 8. Quantity
    quantity = None
    qty_match = re.search(r'(\d+)\s*(?:piece|pieces|pcs|pc|item|items|set)\b', lower)
    if qty_match:
        quantity = qty_match.group(1)
    elif 'single piece' in lower or 'ek piece' in lower or '1 piece' in lower:
        quantity = '1'
    elif 'do piece' in lower or 'pair' in lower or 'joda' in lower:
        quantity = '2'

    # 9. Making Time
    making_time = None
    time_patterns = [
        (r'(\d+)\s*(?:din|days?)\b', lambda m: f"{m.group(1)} days"),
        (r'(\d+)\s*(?:hafte|hafta|weeks?)\b', lambda m: f"{m.group(1)} weeks"),
        (r'(\d+)\s*(?:mahine|mahina|months?)\b', lambda m: f"{m.group(1)} months"),
        (r'(\d+)\s*(?:ghante|ghanta|hours?)\b', lambda m: f"{m.group(1)} hours"),
        (r'\bek\s*din\b', lambda _: "1 day"),
        (r'\bdo\s*din\b', lambda _: "2 days"),
        (r'\bteen\s*din\b', lambda _: "3 days"),
        (r'\bchar\s*din\b', lambda _: "4 days"),
        (r'\bpanch\s*din\b', lambda _: "5 days"),
        (r'\bek\s*hafta\b', lambda _: "1 week"),
        (r'\bdo\s*hafte\b', lambda _: "2 weeks"),
    ]
    for p, formatter in time_patterns:
        m = re.search(p, lower)
        if m:
            making_time = formatter(m)
            break

    # 10. Making Process
    process_hints = []
    if 'wheel' in lower or 'chaak' in lower:
        process_hints.append("Wheel-turned")
    if 'carv' in lower or 'nakkashi' in lower:
        process_hints.append("Hand-carved")
    if 'paint' in lower or 'rang' in lower or 'chitra' in lower:
        process_hints.append("Hand-painted")
    if 'weave' in lower or 'bunai' in lower or 'handloom' in lower:
        process_hints.append("Handloom woven")
    if 'mould' in lower or 'dhalai' in lower:
        process_hints.append("Molded and cured")
    if not process_hints:
        if any(w in lower for w in ['hath se', 'haath se', 'handmade', 'handcrafted']):
            process_hints.append("Completely hand-crafted by artisan")
    making_process = ", ".join(process_hints) if process_hints else None

    # 11. Location
    locations = [
        'Jaipur', 'Varanasi', 'Banaras', 'Lucknow', 'Jodhpur', 'Udaipur',
        'Kutch', 'Surat', 'Ahmedabad', 'Bhopal', 'Indore', 'Kashmir',
        'Srinagar', 'Bengal', 'Kolkata', 'Mysore', 'Bhubaneswar', 'Delhi',
        'Rajasthan', 'Gujarat', 'Uttar Pradesh', 'Madhya Pradesh', 'Odisha',
        'Assam', 'Bihar', 'Tamil Nadu', 'Kerala', 'Karnataka', 'Punjab'
    ]
    location = None
    for loc in locations:
        if re.search(r'\b' + re.escape(loc.lower()) + r'\b', lower):
            location = loc
            break

    # 12. Product Name
    noun_map = [
        ('Decorative Pot', ['matka', 'pot', 'handi', 'ghada', 'ghada', 'kalash']),
        ('Vase', ['vase', 'guldan', 'flower pot']),
        ('Diya Set', ['diya', 'deepak', 'diye']),
        ('Serving Plate', ['plate', 'thali', 'platter']),
        ('Wall Hanging', ['wall hanging', 'jharokha', 'toran']),
        ('Saree', ['saree', 'sari']),
        ('Kurta', ['kurta', 'kurti']),
        ('Shawl', ['shawl', 'dupatta', 'stole']),
        ('Fruit Basket', ['basket', 'tokri']),
        ('Wooden Box', ['box', 'dabba', 'sandook']),
        ('Statue / Idol', ['statue', 'idol', 'murti', 'vigrah']),
        ('Necklace', ['necklace', 'haar', 'chain']),
        ('Earrings', ['earring', 'earrings', 'jhumka', 'jhumke']),
        ('Painting', ['painting', 'chitra', 'portrait']),
        ('Handbag', ['wallet', 'purse', 'bag', 'jhola']),
        ('Pen Stand', ['pen stand', 'desk stand']),
        ('Coasters', ['coaster', 'coasters']),
    ]
    detected_noun = None
    for noun, kws in noun_map:
        for kw in kws:
            if re.search(r'\b' + re.escape(kw) + r'\b', lower):
                detected_noun = noun
                break
        if detected_noun:
            break

    name_parts = []
    if location:
        name_parts.append(location)
    if craft and craft != 'Handcrafted':
        name_parts.append(craft)
    elif material:
        name_parts.append(material)

    if detected_noun:
        name_parts.append(detected_noun)
    elif category:
        name_parts.append(category.split('&')[0].strip())
    else:
        name_parts.append("Handcrafted Craft")

    product_name = " ".join(name_parts)

    # 13. Craft Story
    craft_story = f"Authentic handcrafted {detected_noun or 'creation'} made by skilled artisan"
    if location:
        craft_story += f" in {location}"
    craft_story += ". "
    if material and craft:
        craft_story += f"Created using traditional {craft.lower()} techniques with premium {material.lower()}. "
    elif material:
        craft_story += f"Crafted from high-quality {material.lower()}. "
    if making_time:
        craft_story += f"Takes approximately {making_time} of dedicated craftsmanship to complete."

    return ProductDetails(
        product_name=product_name,
        category=category,
        material=material,
        craft=craft,
        color=color,
        size=size,
        weight=weight,
        quantity=quantity,
        making_time=making_time,
        making_process=making_process,
        location=location,
        price=price,
        craft_story=craft_story,
    )


def extract_product_details(transcript: str) -> ProductDetails:
    """Fast, fail-safe product details extractor.
    Uses sub-millisecond rule-based extraction as primary baseline,
    enriched with Groq compound-mini (or Ollama fallback).
    Never throws 503; always returns valid ProductDetails.
    """
    logger.info(f"Extracting product details ({len(transcript)} chars)")

    # 1. Sub-millisecond baseline extraction
    base_result = extract_fast(transcript)
    base_dict = base_result.model_dump()

    # 2. Try fast Groq enrichment (< 500ms)
    if settings.GROQ_API_KEY:
        try:
            import groq

            groq_client = groq.Groq(api_key=settings.GROQ_API_KEY, timeout=3.0)
            prompt = EXTRACTION_PROMPT.format(transcript=transcript)
            resp = groq_client.chat.completions.create(
                model=settings.GROQ_MODEL or "groq/compound-mini",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1,
                max_tokens=300,
            )
            raw_groq = resp.choices[0].message.content or ""
            parsed = _safe_parse_json(raw_groq)
            if parsed and isinstance(parsed, dict):
                for k, v in parsed.items():
                    if k in base_dict and v is not None and str(v).strip() and str(v).strip().lower() != "null":
                        # If base_dict already has a specific value (like detected craft/material), only overwrite if groq gave something meaningful
                        if base_dict[k] is None or len(str(v)) > len(str(base_dict[k])):
                            base_dict[k] = str(v).strip()
                logger.info("Groq catalog enrichment succeeded.")
                return ProductDetails(**base_dict)
        except Exception as e:
            logger.info(f"Groq catalog enrichment skipped/failed: {e}. Trying Ollama or baseline.")

    # 3. Try fast Ollama enrichment with 2.0s strict timeout
    try:
        client = _get_client()
        prompt = EXTRACTION_PROMPT.format(transcript=transcript)
        resp = client.post(
            "/api/generate",
            json={
                "model": settings.OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False,
                "format": "json",
                "options": {
                    "temperature": 0.1,
                    "num_predict": 120,
                },
            },
            timeout=httpx.Timeout(2.0, connect=1.0),
        )
        if resp.status_code == 200:
            raw_response = resp.json().get("response", "")
            parsed = _safe_parse_json(raw_response)
            if parsed and isinstance(parsed, dict):
                for k, v in parsed.items():
                    if k in base_dict and v is not None and str(v).strip() and str(v).strip().lower() != "null":
                        base_dict[k] = str(v).strip()
                logger.info("Ollama enrichment succeeded.")
                return ProductDetails(**base_dict)
    except Exception as e:
        logger.info(f"Ollama fast enrichment skipped/timed-out: {e}.")

    logger.info("Baseline extraction complete.")
    return ProductDetails(**base_dict)
