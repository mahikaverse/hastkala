import json
import re

from ..core.config import settings


MARKETPLACE_PROMPTS = {
    "amazon": """You are an Amazon product listing expert. Given a handcrafted Indian product, generate:
1. An optimized product title (max 200 chars, include key attributes)
2. Five bullet points highlighting features, material, craft, and use cases
3. A product description (2-3 paragraphs, compelling and factual)
4. Seven search keywords (relevant to Indian handcrafted products)

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep factual accuracy — only format and enhance existing information
- Use natural, compelling Amazon-style copy
- Mention "handmade" and "artisan" where appropriate
- Return ONLY valid JSON with keys: title, bulletPoints (list of strings), description, keywords (list of strings)""",

    "flipkart": """You are a Flipkart product listing expert. Given a handcrafted Indian product, generate:
1. An SEO-friendly product name (max 150 chars)
2. A compelling product description (2-3 paragraphs)
3. 3-5 product highlights (short, punchy points)
4. Five search keywords

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep factual accuracy — only format and enhance existing information
- Use Flipkart-style listing format
- Return ONLY valid JSON with keys: title, description, highlights (list of strings), keywords (list of strings)""",

    "blinkit": """You are a Blinkit product listing expert. Given a handcrafted Indian product, generate:
1. A short, catchy product name (max 60 chars)
2. A brief, punchy description (1-2 sentences max)
3. A category label (short, 2-3 words)

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep it ultra-concise — Blinkit style is minimal and quick
- Focus on what makes the product special in one line
- Return ONLY valid JSON with keys: title, description, category""",

    "other": """You are a multi-marketplace product listing expert. Given a handcrafted Indian product, generate:
1. A universal product title (clear, descriptive, max 150 chars)
2. A comprehensive product description (2-3 paragraphs)
3. Five search keywords
4. 3-5 key product highlights

Rules:
- NEVER invent material, dimensions, certifications, or origin claims
- NEVER change the price
- Keep factual accuracy — only format and enhance existing information
- Make it work across multiple platforms (Meesho, JioMart, etc.)
- Return ONLY valid JSON with keys: title, description, keywords (list of strings), highlights (list of strings)""",
}


def _build_user_prompt(data: dict) -> str:
    parts = [
        f"Product: {data['product_name']}",
        f"Description: {data.get('description') or 'N/A'}",
        f"Material: {data.get('material') or 'N/A'}",
        f"Craft: {data.get('craft_type') or 'N/A'}",
        f"Category: {data.get('category') or 'N/A'}",
        f"Price: ₹{int(data['price'])}",
        f"Color: {data.get('color') or 'N/A'}",
        f"Size: {data.get('size') or 'N/A'}",
        f"Weight: {data.get('weight') or 'N/A'}",
    ]
    if data.get("existing_bullet_points"):
        parts.append(f"Existing features: {', '.join(data['existing_bullet_points'])}")
    if data.get("existing_keywords"):
        parts.append(f"Existing tags: {', '.join(data['existing_keywords'])}")
    return "\n".join(parts)


def _extract_json(text: str) -> dict | None:
    # Try markdown code block
    match = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1).strip())
        except json.JSONDecodeError:
            pass
    # Try raw JSON
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(0))
        except json.JSONDecodeError:
            pass
    return None


async def prepare_listing(data: dict) -> dict | None:
    """Use Groq to prepare a marketplace-optimized listing."""
    marketplace = data.get("marketplace", "other")
    system_prompt = MARKETPLACE_PROMPTS.get(marketplace, MARKETPLACE_PROMPTS["other"])
    user_prompt = _build_user_prompt(data)

    try:
        import httpx
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                "https://api.groq.com/openai/v1/chat/completions",
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {settings.GROQ_API_KEY}",
                },
                json={
                    "model": settings.GROQ_MODEL,
                    "messages": [
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt},
                    ],
                    "temperature": 0.7,
                    "max_tokens": 800,
                },
            )
            if resp.status_code == 200:
                result = resp.json()
                content = result["choices"][0]["message"]["content"].strip()
                ai_data = _extract_json(content)
                if ai_data:
                    # Price is NEVER changed by AI
                    ai_data["price"] = data["price"]
                    return ai_data
    except Exception:
        pass

    return None
