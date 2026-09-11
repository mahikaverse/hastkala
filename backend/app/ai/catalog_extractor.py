import json
import logging
import re
from typing import Optional

import httpx

from app.core.config import settings
from app.schemas.catalog import ProductDetails

logger = logging.getLogger("hastkala.ai.extractor")

_client: Optional[httpx.Client] = None

EXTRACTION_PROMPT_ALL = """You are an expert product data extractor for Indian handicraft artisans.
Extract the facts explicitly stated or strongly implied in the transcript below into valid JSON.
Transcript: "{transcript}"

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
  "craft_story": null,
  "artisan_intro": null
}}"""

EXTRACTION_PROMPT_STEP1 = """You are an expert product catalog assistant for Indian artisans.
Extract Product Basic Details from this artisan's speech into valid JSON.
Speech: "{transcript}"

Extract:
- product_name: A clear, attractive product title (e.g. "Handcrafted Terracotta Blue Diya")
- category: One of [Pottery & Ceramics, Woodwork, Textiles & Handloom, Jewelry & Accessories, Metal Craft, Paintings & Art, Bamboo & Cane, Leather Craft, Stone Craft, Other]
- material: Material used (e.g. Terracotta clay, Sheesham wood, Pure silk, Brass, etc.)
- craft: Traditional craft/technique (e.g. Blue Pottery, Hand Carving, Chikankari, Dhokra Art, Handloom Weaving, etc.)
- color: Colors mentioned (e.g. Terracotta Red, Sky Blue, Multicolored, etc.)
- size: Dimensions or size (e.g. 6 inches, Medium, 12x8 cm)
- weight: Weight (e.g. 500 grams, 1 kg)

Output valid JSON ONLY with these exact keys:
{{
  "product_name": null,
  "category": null,
  "material": null,
  "craft": null,
  "color": null,
  "size": null,
  "weight": null
}}"""

EXTRACTION_PROMPT_STEP2 = """You are an assistant for Indian handicraft artisans.
Extract Quantity & Production Capacity details from this speech into valid JSON.
Speech: "{transcript}"

Extract:
- quantity: Ready stock count as a number or string (e.g. "10", "25", "1")
- production_capacity: How many pieces the artisan can make per month/week (e.g. "50 pieces per month", "10 pieces per week")
- making_time: Time required to make one piece or batch (e.g. "2 days", "3 hours", "1 week")
- making_process: Brief summary of the technique or steps (e.g. "Wheel-thrown, kiln baked, hand polished and painted")

Output valid JSON ONLY with these exact keys:
{{
  "quantity": null,
  "production_capacity": null,
  "making_time": null,
  "making_process": null
}}"""

EXTRACTION_PROMPT_STEP3 = """You are a master storyteller celebrating Indian handicraft artisans.
From this artisan's speech, extract and generate an authentic, captivating origin story and background into valid JSON.
Speech: "{transcript}"

Extract:
- craft_story: A rich, beautiful 2-4 sentence narrative celebrating the heritage, history, and craft tradition of this product. Highlight the artisan's dedication and cultural roots.
- location: City, town, or state where this craft is practiced (e.g. "Jaipur, Rajasthan", "Varanasi, Uttar Pradesh")
- artisan_intro: Brief artisan background, lineage, or experience (e.g. "Master artisan with 20 years of experience continuing a 3-generation family tradition")

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


def _call_ollama(prompt: str, timeout: float = 25.0) -> Optional[dict]:
    """Primary LLM: Ollama (local qwen2.5:3b)."""
    try:
        logger.info(f"Calling Ollama at {settings.OLLAMA_BASE_URL} (model={settings.OLLAMA_MODEL})...")
        with httpx.Client(base_url=settings.OLLAMA_BASE_URL, timeout=httpx.Timeout(timeout, connect=3.0)) as client:
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
        logger.warning(f"Ollama extraction failed/timed-out: {e}. Falling back to Groq...")
    return None


def _call_groq(prompt: str, timeout: float = 8.0) -> Optional[dict]:
    """Fallback LLM: Groq API (groq/compound-mini or settings.GROQ_MODEL)."""
    if not settings.GROQ_API_KEY:
        logger.warning("Groq API key not configured, skipping Groq fallback.")
        return None
    try:
        import groq

        model_to_use = settings.GROQ_MODEL if settings.GROQ_MODEL and settings.GROQ_MODEL != "groq/compound-mini" else "groq/compound-mini"
        logger.info(f"Calling Groq fallback (model={model_to_use})...")
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
            logger.info("Groq fallback extraction succeeded!")
            return parsed
    except Exception as e:
        logger.warning(f"Groq fallback extraction failed: {e}")
    return None


def extract_with_llm(prompt: str) -> Optional[dict]:
    """Strictly use Ollama as primary, Groq as fallback."""
    # 1. Primary: Ollama
    result = _call_ollama(prompt)
    if result:
        return result

    # 2. Fallback: Groq
    result = _call_groq(prompt)
    if result:
        return result

    return None


def extract_fast(transcript: str) -> ProductDetails:
    """Sub-millisecond regex & keyword extraction for Indian handicrafts.
    Runs without network dependency and guarantees baseline accuracy.
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

    # 8. Quantity (Ready Stock)
    quantity = None
    qty_match = re.search(r'(\d+)\s*(?:piece|pieces|pcs|pc|item|items|set)\b', lower)
    if qty_match:
        quantity = qty_match.group(1)
    elif 'single piece' in lower or 'ek piece' in lower or '1 piece' in lower:
        quantity = '1'
    elif 'do piece' in lower or 'pair' in lower or 'joda' in lower:
        quantity = '2'

    # 9. Production Capacity (Kitna bana sakte ho)
    production_capacity = None
    cap_match = re.search(r'(\d+)\s*(?:piece|pcs|item)?\s*(?:mahine|month|hafte|week|din|day)\s*(?:me|mein)?\s*(?:bana sakte|ban sakte|supply)', lower)
    if cap_match:
        production_capacity = f"{cap_match.group(1)} pieces"
    elif '50 piece' in lower:
        production_capacity = "50 pieces per month"
    elif '100 piece' in lower:
        production_capacity = "100 pieces per month"

    # 10. Making Time
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

    # 11. Making Process
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
    if not process_hints:
        if any(w in lower for w in ['hath se', 'haath se', 'handmade', 'handcrafted']):
            process_hints.append("Completely handcrafted by artisan")
    making_process = ", ".join(process_hints) if process_hints else None

    # 12. Location
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

    # 13. Product Name
    noun_map = [
        ('Decorative Pot', ['matka', 'pot', 'handi', 'ghada', 'kalash']),
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
        name_parts.append("Handcrafted Artwork")

    product_name = " ".join(name_parts)

    # 14. Craft Story
    craft_story = f"Authentic handcrafted {detected_noun or 'creation'} made by skilled artisan"
    if location:
        craft_story += f" in {location}"
    craft_story += ". "
    if material and craft:
        craft_story += f"Created using traditional {craft.lower()} techniques with premium {material.lower()}. "
    elif material:
        craft_story += f"Crafted from natural {material.lower()}. "
    if making_time:
        craft_story += f"Takes approximately {making_time} of dedicated craftsmanship to complete."

    artisan_intro = f"Dedicated handicraft artisan practicing traditional {craft or 'heritage'} art in {location or 'India'}."

    return ProductDetails(
        product_name=product_name,
        category=category,
        material=material,
        craft=craft,
        color=color,
        size=size,
        weight=weight,
        quantity=quantity,
        production_capacity=production_capacity,
        making_time=making_time,
        making_process=making_process,
        location=location,
        price=price,
        craft_story=craft_story,
        artisan_intro=artisan_intro,
    )


def extract_step1_product_details(transcript: str) -> dict:
    """Step 1: Extract Product Name, Category, Material, Craft, Color, Size, Weight.
    Primary: Ollama, Fallback: Groq, Final: Fast Regex.
    """
    logger.info(f"Extract Step 1: '{transcript[:50]}...'")
    base = extract_fast(transcript).model_dump()

    prompt = EXTRACTION_PROMPT_STEP1.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        for k in ["product_name", "category", "material", "craft", "color", "size", "weight"]:
            val = llm_data.get(k)
            if val is not None and str(val).strip() and str(val).strip().lower() != "null":
                base[k] = str(val).strip()

    return {
        "product_name": base.get("product_name"),
        "category": base.get("category"),
        "material": base.get("material"),
        "craft": base.get("craft"),
        "color": base.get("color"),
        "size": base.get("size"),
        "weight": base.get("weight"),
    }


def extract_step2_quantity_details(transcript: str) -> dict:
    """Step 2: Extract Quantity, Capacity, Making Time, Making Process.
    Primary: Ollama, Fallback: Groq, Final: Fast Regex.
    """
    logger.info(f"Extract Step 2: '{transcript[:50]}...'")
    base = extract_fast(transcript).model_dump()

    prompt = EXTRACTION_PROMPT_STEP2.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        for k in ["quantity", "production_capacity", "making_time", "making_process"]:
            val = llm_data.get(k)
            if val is not None and str(val).strip() and str(val).strip().lower() != "null":
                base[k] = str(val).strip()

    return {
        "quantity": base.get("quantity"),
        "production_capacity": base.get("production_capacity"),
        "making_time": base.get("making_time"),
        "making_process": base.get("making_process"),
    }


def extract_step3_story_details(transcript: str) -> dict:
    """Step 3: Extract & generate Craft Origin Story, Location, Artisan Lineage.
    Primary: Ollama, Fallback: Groq, Final: Fast Regex.
    """
    logger.info(f"Extract Step 3: '{transcript[:50]}...'")
    base = extract_fast(transcript).model_dump()

    prompt = EXTRACTION_PROMPT_STEP3.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        for k in ["craft_story", "location", "artisan_intro"]:
            val = llm_data.get(k)
            if val is not None and str(val).strip() and str(val).strip().lower() != "null":
                base[k] = str(val).strip()

    return {
        "craft_story": base.get("craft_story"),
        "location": base.get("location"),
        "artisan_intro": base.get("artisan_intro"),
    }


def extract_product_details(transcript: str) -> ProductDetails:
    """Extract complete product details.
    Primary: Ollama, Fallback: Groq, Final: Fast Regex.
    Never fails, always returns valid ProductDetails.
    """
    logger.info(f"Extract Full Catalog ({len(transcript)} chars)")
    base = extract_fast(transcript).model_dump()

    prompt = EXTRACTION_PROMPT_ALL.format(transcript=transcript)
    llm_data = extract_with_llm(prompt)

    if llm_data:
        for k in base.keys():
            val = llm_data.get(k)
            if val is not None and str(val).strip() and str(val).strip().lower() != "null":
                base[k] = str(val).strip()

    return ProductDetails(**base)
