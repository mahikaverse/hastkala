import json
import logging
import re
from typing import Optional

import httpx

from app.core.config import settings
from app.schemas.catalog import ProductDetails

logger = logging.getLogger("hastkala.ai.extractor")

_client: Optional[httpx.Client] = None

# ──────────────────────────────────────────────────────────────
# LLM PROMPTS — Factual extraction only. No invention allowed.
# ──────────────────────────────────────────────────────────────

EXTRACTION_PROMPT_ALL = """You are a factual product data extractor for Indian artisans.
Extract ONLY the facts explicitly stated or clearly implied by the artisan in the transcript below.

Transcript: "{transcript}"

IMPORTANT: The transcript may be in Hindi, Hinglish, or English. ALL output values MUST be in English.
Translate Hindi/Hinglish terms to English naturally. Examples:
- "bamboo ki tokri" → material: "Bamboo", product_name: "Bamboo Basket"
- "mitti ke diye" → material: "Clay", product_name: "Clay Diya"
- "brown colour hai" → color: "Brown"
- "baarah inch" → size: "12 inch"

STRICT RULES:
- Extract ONLY what the artisan actually said.
- Do NOT invent, assume, or embellish any information.
- If the artisan did NOT mention something, set it to null.
- Do NOT use words like "handcrafted", "handmade", "traditional", "premium", "ancient", "heritage" unless the artisan literally said those words.
- Product name must be derived from the actual product described (e.g. "Bamboo Basket", "Clay Diya").
- Category must be inferred from the actual product/material (e.g. Bamboo & Cane, Pottery & Ceramics).
- description: MUST contain at least 2 factual sentences based ONLY on what was said. Do NOT add words like "premium", "traditional", "handcrafted" unless the artisan literally said them. Each sentence must be based on verified information.

Output valid JSON ONLY with these exact keys:
{{
  "product_name": null,
  "category": null,
  "material": null,
  "craft": null,
  "color": null,
  "size": null,
  "weight": null,
  "quantity": null,
  "production_capacity": null,
  "making_time": null,
  "making_process": null,
  "location": null,
  "price": null,
  "description": null,
  "craft_story": null,
  "artisan_intro": null
}}"""

EXTRACTION_PROMPT_STEP1 = """You are a factual product data extractor for Indian artisans.
Extract ONLY the product basic details that the artisan explicitly mentions in their speech.

Speech: "{transcript}"

IMPORTANT: The transcript may be in Hindi, Hinglish, or English. ALL output values MUST be in English.
Translate Hindi/Hinglish terms to English naturally. Examples:
- "bamboo ki tokri" → material: "Bamboo", product_name: "Bamboo Basket"
- "mitti ke diye" → material: "Clay", product_name: "Clay Diya"
- "brown colour hai" → color: "Brown"
- "baarah inch" → size: "12 inch"
- "teen din" → making_time: "3 days"

STRICT RULES:
- Extract ONLY what the artisan actually said.
- Do NOT invent, assume, or embellish any information.
- If something was NOT mentioned, set it to null.
- Do NOT use generic filler words like "handcrafted", "handmade", "traditional", "premium".
- Product name must be the actual product described in English. Examples:
  - "Mai bamboo ki tokri banata hu" → product_name: "Bamboo Basket"
  - "Mai mitti ke diye banata hu" → product_name: "Clay Diya"
  - "Mai blue pottery ka vase banata hu" → product_name: "Blue Pottery Vase"
  - NEVER: "Handcrafted Item", "Handmade Craft", "Handicraft Product"
- Category must match the actual product/material:
  - Bamboo/Cane products → "Bamboo & Cane"
  - Clay/Terracotta/Pottery → "Pottery & Ceramics"
  - Silk/Cotton/Saree/Kurta → "Textiles & Handloom"
  - Brass/Copper/Bronze metal items → "Metal Craft"
  - Wood/Wooden items → "Woodwork"
  - Jewelry items → "Jewelry & Accessories"
  - Paintings → "Paintings & Art"
  - Leather items → "Leather Craft"
  - Stone/Marble items → "Stone Craft"
  - Anything else → "Other"
  - Do NOT force a product into a handicraft category if it doesn't belong there.
- description: MUST contain at least 2 factual sentences based ONLY on what was said. Do NOT add words like "premium", "traditional", "handcrafted" unless the artisan literally said them. Each sentence must be based on verified information. Examples:
  - "Bamboo basket" → "This product is a bamboo basket. It is made from bamboo."
  - "Blue vase" → "This product is a blue vase. It is available in a blue color."
  - "Bamboo basket, brown color, 12 inch, takes 3 days to make" → "This bamboo basket is brown in color and measures 12 inches. It takes approximately three days to make."

Output valid JSON ONLY with these exact keys:
{{
  "product_name": null,
  "category": null,
  "material": null,
  "craft": null,
  "color": null,
  "size": null,
  "weight": null,
  "description": null
}}"""

EXTRACTION_PROMPT_STEP2 = """You are a factual data extractor for Indian artisans.
Extract ONLY the quantity and production details that the artisan explicitly mentions.

Speech: "{transcript}"

IMPORTANT: The transcript may be in Hindi, Hinglish, or English. ALL output values MUST be in English.
Translate Hindi/Hinglish numbers and terms to English. Examples:
- "pachaas piece" → quantity: "50"
- "sau piece" → quantity: "100"
- "bees piece har hafte" → production_capacity: "20 per week"
- "do ghante" → making_time: "2 hours"
- "hafta" → use "week", "mahina" → use "month"

STRICT RULES:
- Extract ONLY what the artisan actually said.
- Do NOT invent or assume any information.
- If something was NOT mentioned, set it to null.

Output valid JSON ONLY with these exact keys:
{{
  "quantity": null,
  "production_capacity": null,
  "making_time": null,
  "making_process": null
}}"""

EXTRACTION_PROMPT_STEP3 = """You are a factual data extractor for Indian artisans.
Extract ONLY the craft story, location, and artisan intro that the artisan explicitly shares.

Speech: "{transcript}"

IMPORTANT: The transcript may be in Hindi, Hinglish, or English. ALL output values MUST be in English.
Translate Hindi/Hinglish terms to English naturally.

STRICT RULES:
- Extract ONLY what the artisan actually said about their story, location, and background.
- Do NOT invent fictional stories, heritage claims, or cultural narratives.
- If the artisan did NOT share a personal story, set craft_story to null.
- If the artisan did NOT mention their location, set location to null.
- If the artisan did NOT introduce themselves, set artisan_intro to null.
- Do NOT use phrases like "ancient tradition", "passed down for centuries", "India's rich cultural heritage" unless the artisan literally said those words.
- craft_story should only contain what the artisan actually shared about how they learned the craft or their experience.
- artisan_intro should only contain the artisan's name and any background they actually provided.

Output valid JSON ONLY with these exact keys:
{{
  "craft_story": null,
  "location": null,
  "artisan_intro": null
}}"""


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


def _call_ollama(prompt: str, timeout: float = 5.0) -> Optional[dict]:
    """Fallback LLM: Ollama (local qwen2.5:3b)."""
    try:
        logger.info(f"Calling Ollama at {settings.OLLAMA_BASE_URL} (model={settings.OLLAMA_MODEL})...")
        with httpx.Client(base_url=settings.OLLAMA_BASE_URL, timeout=httpx.Timeout(timeout, connect=1.5)) as client:
            resp = client.post(
                "/api/generate",
                json={
                    "model": settings.OLLAMA_MODEL,
                    "prompt": prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,
                        "num_predict": 300,
                    },
                },
            )
            if resp.status_code == 200:
                raw_text = resp.json().get("response", "")
                parsed = _safe_parse_json(raw_text)
                if parsed and isinstance(parsed, dict):
                    logger.info("Ollama extraction succeeded!")
                    return parsed
    except Exception as e:
        logger.warning(f"Ollama extraction failed/timed-out: {e}")
    return None


def _call_groq(prompt: str, timeout: float = 8.0) -> Optional[dict]:
    """Primary LLM: Groq API (ultra-fast cloud LPU)."""
    if not settings.GROQ_API_KEY:
        logger.warning("Groq API key not configured, skipping Groq.")
        return None
    try:
        import groq

        # Fix invalid model names — groq/compound-mini does not exist
        model_to_use = settings.GROQ_MODEL
        if not model_to_use or model_to_use.startswith("groq/"):
            model_to_use = "qwen/qwen3.8-27b"
        logger.info(f"Calling Groq (model={model_to_use})...")
        groq_client = groq.Groq(api_key=settings.GROQ_API_KEY, timeout=timeout)
        resp = groq_client.chat.completions.create(
            model=model_to_use,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.1,
            max_tokens=350,
        )
        raw_text = resp.choices[0].message.content or ""
        parsed = _safe_parse_json(raw_text)
        if parsed and isinstance(parsed, dict):
            logger.info("Groq extraction succeeded!")
            return parsed
    except Exception as e:
        logger.warning(f"Groq extraction failed: {e}")
    return None


def extract_with_llm(prompt: str) -> Optional[dict]:
    """Fast extraction: Try Groq first for instant (<1s) response, fallback to Ollama."""
    if settings.GROQ_API_KEY:
        result = _call_groq(prompt)
        if result:
            return result

    result = _call_ollama(prompt)
    if result:
        return result

    return None


def _clean_null(value) -> Optional[str]:
    """Return None if value is None, empty, or the string 'null'."""
    if value is None:
        return None
    s = str(value).strip()
    if not s or s.lower() == "null":
        return None
    return s


def extract_fast(transcript: str) -> ProductDetails:
    """Sub-millisecond regex extraction for numeric/factual data only.
    This extracts: price, material, size, weight, quantity, making_time, location, color.
    It does NOT generate: product_name, craft, craft_story, artisan_intro, description.
    Those must come from the LLM.
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

    # 3. Color
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

    # 4. Size
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

    # 5. Weight
    weight = None
    weight_match = re.search(r'(\d+(?:\.\d+)?\s*(?:gram|grams|gm|gms|g|kg|kilogram|kilo)\b)', lower)
    if weight_match:
        weight = weight_match.group(1).strip()
    elif 'aadha kilo' in lower or 'aadha kg' in lower:
        weight = '500 g'
    elif 'ek kilo' in lower or '1 kilo' in lower:
        weight = '1 kg'

    # 6. Quantity (Ready Stock)
    quantity = None
    qty_match = re.search(r'(\d+)\s*(?:piece|pieces|pcs|pc|item|items|set)\b', lower)
    if qty_match:
        quantity = qty_match.group(1)
    elif 'single piece' in lower or 'ek piece' in lower or '1 piece' in lower:
        quantity = '1'
    elif 'do piece' in lower or 'pair' in lower or 'joda' in lower:
        quantity = '2'

    # 7. Production Capacity
    production_capacity = None
    cap_match = re.search(r'(\d+)\s*(?:piece|pcs|item)?\s*(?:mahine|month|hafte|week|din|day)\s*(?:me|mein)?\s*(?:bana sakte|ban sakte|supply)', lower)
    if cap_match:
        production_capacity = f"{cap_match.group(1)} pieces"

    # 8. Making Time
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

    # 9. Making Process - only extract if explicitly mentioned
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
    if 'bhatti' in lower or 'kiln' in lower or 'baked' in lower:
        process_hints.append("Kiln-baked")
    making_process = ", ".join(process_hints) if process_hints else None

    # 10. Location - only if explicitly mentioned
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

    return ProductDetails(
        category=None,
        material=material,
        color=color,
        size=size,
        weight=weight,
        quantity=quantity,
        production_capacity=production_capacity,
        making_time=making_time,
        making_process=making_process,
        location=location,
        price=price,
    )


def extract_step1_product_details(transcript: str) -> dict:
    """Step 1: Product Name, Category, Material, Craft, Color, Size, Weight.
    LLM is PRIMARY for semantic fields (name, category, craft).
    Regex only fills numeric/factual gaps that LLM may miss.
    """
    logger.info(f"Extract Step 1: '{transcript[:50]}...'")

    prompt = EXTRACTION_PROMPT_STEP1.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    # Start with regex-extracted numeric/factual data as baseline
    fast = extract_fast(transcript).model_dump()
    base = {k: _clean_null(v) for k, v in fast.items()}

    # LLM is the primary source — it decides product_name, category, craft, description
    if llm_data:
        semantic_keys = ["product_name", "category", "craft", "description"]
        for k in semantic_keys:
            val = _clean_null(llm_data.get(k))
            if val is not None:
                base[k] = val
            else:
                # LLM explicitly said null → don't let regex fill it
                base[k] = None

        # For factual fields, LLM overrides regex if present, else keep regex
        factual_keys = ["material", "color", "size", "weight"]
        for k in factual_keys:
            llm_val = _clean_null(llm_data.get(k))
            if llm_val is not None:
                base[k] = llm_val
    else:
        # LLM failed — use regex only for what it can do
        base["product_name"] = None
        base["category"] = None
        base["craft"] = None
        base["description"] = None

    return {
        "product_name": _clean_null(base.get("product_name")),
        "category": _clean_null(base.get("category")),
        "material": _clean_null(base.get("material")),
        "craft": _clean_null(base.get("craft")),
        "color": _clean_null(base.get("color")),
        "size": _clean_null(base.get("size")),
        "weight": _clean_null(base.get("weight")),
        "description": _clean_null(base.get("description")),
    }


def extract_step2_quantity_details(transcript: str) -> dict:
    """Step 2: Quantity, Capacity, Making Time, Making Process.
    Regex is primary for numbers. LLM fills gaps.
    """
    logger.info(f"Extract Step 2: '{transcript[:50]}...'")

    fast = extract_fast(transcript).model_dump()
    base = {k: _clean_null(v) for k, v in fast.items()}

    prompt = EXTRACTION_PROMPT_STEP2.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        for k in ["quantity", "production_capacity", "making_time", "making_process"]:
            llm_val = _clean_null(llm_data.get(k))
            if llm_val is not None:
                base[k] = llm_val

    return {
        "quantity": _clean_null(base.get("quantity")),
        "production_capacity": _clean_null(base.get("production_capacity")),
        "making_time": _clean_null(base.get("making_time")),
        "making_process": _clean_null(base.get("making_process")),
    }


def extract_step3_story_details(transcript: str) -> dict:
    """Step 3: Craft Story, Location, Artisan Intro.
    LLM is PRIMARY. Only extracts what artisan actually shared.
    """
    logger.info(f"Extract Step 3: '{transcript[:50]}...'")

    fast = extract_fast(transcript).model_dump()
    base = {k: _clean_null(v) for k, v in fast.items()}

    prompt = EXTRACTION_PROMPT_STEP3.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        for k in ["craft_story", "location", "artisan_intro"]:
            val = _clean_null(llm_data.get(k))
            # Use LLM result (even if null — that means artisan didn't share)
            base[k] = val
    else:
        # LLM failed — no story generation from regex
        base["craft_story"] = None
        base["artisan_intro"] = None

    return {
        "craft_story": _clean_null(base.get("craft_story")),
        "location": _clean_null(base.get("location")),
        "artisan_intro": _clean_null(base.get("artisan_intro")),
    }


def extract_product_details(transcript: str) -> ProductDetails:
    """Extract complete product details.
    LLM is PRIMARY. Regex fills numeric gaps only.
    """
    logger.info(f"Extract Full Catalog ({len(transcript)} chars)")

    fast = extract_fast(transcript).model_dump()
    base = {k: _clean_null(v) for k, v in fast.items()}

    prompt = EXTRACTION_PROMPT_ALL.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        # Semantic fields — LLM decides, null if LLM says null
        for k in ["product_name", "category", "craft", "description", "craft_story", "artisan_intro"]:
            val = _clean_null(llm_data.get(k))
            base[k] = val

        # Factual fields — LLM overrides if present, else keep regex
        for k in ["material", "color", "size", "weight", "quantity", "production_capacity",
                   "making_time", "making_process", "location", "price"]:
            llm_val = _clean_null(llm_data.get(k))
            if llm_val is not None:
                base[k] = llm_val
    else:
        # LLM failed — null out fields it should have decided
        base["product_name"] = None
        base["category"] = None
        base["craft"] = None
        base["description"] = None
        base["craft_story"] = None
        base["artisan_intro"] = None

    return ProductDetails(**{k: v for k, v in base.items() if k in ProductDetails.model_fields})
