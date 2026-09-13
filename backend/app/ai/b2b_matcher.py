import json
import logging
import re
from typing import Any, Dict, List, Optional

from app.core.config import settings
from app.core.supabase import get_supabase
from app.schemas.b2b import B2BMatchedArtisan, B2BMatchResponse, B2BRequirementMatchRequest

logger = logging.getLogger("hastkala.ai.b2b_matcher")

FALLBACK_ARTISANS = [
    {
        "id": "a1000000-0000-0000-0000-000000000001",
        "name": "Meera Devi",
        "craft_specialization": "Block Printing",
        "location": "Jaipur",
        "state": "Rajasthan",
        "years_of_experience": 18,
        "average_rating": 4.8,
        "total_reviews": 42,
        "is_verified": True,
        "avatar_url": "",
        "bio": "Master block printer from Jaipur carrying forward a 200-year-old family tradition. Specializes in organic dyes, hand-carved wooden blocks, bedsheets, dupattas, and kurtas.",
    },
    {
        "id": "a1000000-0000-0000-0000-000000000002",
        "name": "Ramesh Kumar",
        "craft_specialization": "Blue Pottery",
        "location": "Jaipur",
        "state": "Rajasthan",
        "years_of_experience": 25,
        "average_rating": 4.9,
        "total_reviews": 56,
        "is_verified": True,
        "avatar_url": "",
        "bio": "Award-winning blue pottery artisan from Jaipur. Fifth generation potter creating tiles, tea sets, vases, tableware, and custom decorative pieces.",
    },
    {
        "id": "a1000000-0000-0000-0000-000000000003",
        "name": "Kavita Sharma",
        "craft_specialization": "Handloom & Silk",
        "location": "Varanasi",
        "state": "Uttar Pradesh",
        "years_of_experience": 22,
        "average_rating": 4.7,
        "total_reviews": 38,
        "is_verified": True,
        "avatar_url": "",
        "bio": "Weaver from Varanasi specializing in Banarasi silk. Creates exquisite sarees, dupattas, stoles, and fabrics with real zari work using traditional pit looms.",
    },
    {
        "id": "a1000000-0000-0000-0000-000000000004",
        "name": "Arjun Boro",
        "craft_specialization": "Bamboo & Cane",
        "location": "Guwahati",
        "state": "Assam",
        "years_of_experience": 15,
        "average_rating": 4.6,
        "total_reviews": 29,
        "is_verified": True,
        "avatar_url": "",
        "bio": "Bamboo craftsman from Assam creating sustainable home decor, baskets, lamps, and furniture. Uses eco-friendly techniques passed down through Bodo tribal traditions.",
    },
    {
        "id": "a1000000-0000-0000-0000-000000000005",
        "name": "Sita Nair",
        "craft_specialization": "Woodcarving",
        "location": "Thrissur",
        "state": "Kerala",
        "years_of_experience": 20,
        "average_rating": 4.8,
        "total_reviews": 35,
        "is_verified": True,
        "avatar_url": "",
        "bio": "Woodcarver from Kerala specializing in rosewood and teak. Creates intricate temple jewelry boxes, sculptures, wall panels, and decor using traditional Chola-style carving.",
    },
    {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "name": "Anand Kumar",
        "craft_specialization": "Terracotta & Pottery",
        "location": "Jaipur",
        "state": "Rajasthan",
        "years_of_experience": 12,
        "average_rating": 4.5,
        "total_reviews": 19,
        "is_verified": False,
        "avatar_url": "",
        "bio": "Skilled artisan specializing in terracotta cookware, kullads, clay pots, and decorative earthen planters.",
    },
]


def fetch_all_artisans() -> List[Dict[str, Any]]:
    """Fetch active artisans from Supabase, or use fallback list if empty/offline."""
    try:
        supabase = get_supabase()
        res = (
            supabase.table("artisans")
            .select(
                "id, name, avatar_url, craft_specialization, location, state, years_of_experience, bio, average_rating, total_reviews, is_verified"
            )
            .execute()
        )
        if res.data and len(res.data) > 0:
            logger.info(f"Loaded {len(res.data)} artisans from Supabase.")
            return res.data
    except Exception as e:
        logger.warning(f"Failed to fetch artisans from Supabase: {e}. Using fallback data.")

    return FALLBACK_ARTISANS


def _clean_json_str(text: str) -> str:
    """Extract JSON object from markdown blocks or raw text and clean common syntax issues."""
    text = text.strip()
    if "```" in text:
        text = re.sub(r"^```(?:json)?\s*", "", text, flags=re.MULTILINE)
        text = re.sub(r"```$", "", text, flags=re.MULTILINE)
        text = text.strip()
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if match:
        text = match.group(0)
    # Remove trailing commas before } or ]
    text = re.sub(r",\s*([\]}])", r"\1", text)
    return text


def _local_fallback_match(
    req: B2BRequirementMatchRequest, artisans: List[Dict[str, Any]]
) -> B2BMatchResponse:
    """Intelligent multi-factor artisan matcher with differentiated, realistic scores."""
    keywords = [
        (req.title or "").lower(),
        (req.category or "").lower(),
        (req.craft_type or "").lower(),
        (req.material or "").lower(),
        (req.description or "").lower(),
    ]
    all_text = " ".join(keywords)

    ranked: List[B2BMatchedArtisan] = []

    # Semantic craft keyword groups
    craft_groups = {
        "textile": ["silk", "handloom", "textile", "saree", "dupatta", "weave", "cotton", "khadi", "kurta", "scarf", "apparel", "dress", "chanderi", "bandhani", "zari", "block print", "fabric", "linen"],
        "pottery": ["pottery", "ceramic", "terracotta", "clay", "cup", "kullad", "plate", "vase", "diya", "bowl", "planter", "pot", "bottle", "earthen", "mud", "jug", "glass"],
        "block_print": ["block", "print", "fabric", "pattern", "bag", "stamps", "bedsheet", "curtain", "dyes"],
        "bamboo": ["bamboo", "cane", "basket", "lamp", "grass", "eco", "straw", "jute", "mat", "coaster", "tray"],
        "wood": ["wood", "wooden", "carving", "box", "sculpture", "furniture", "teak", "sheesham", "rosewood", "panel", "frame"],
        "metal": ["brass", "copper", "bronze", "metal", "dhokra", "pital", "loha", "iron", "bell metal", "utensil", "idol"],
    }

    scored_items = []

    for a in artisans:
        spec = (a.get("craft_specialization") or "").lower()
        bio = (a.get("bio") or "").lower()
        loc = (a.get("location") or "").lower()
        state = (a.get("state") or "").lower()
        exp = int(a.get("years_of_experience") or 0)
        rating = float(a.get("average_rating") or 0.0)
        verified = bool(a.get("is_verified") or False)

        score = 44  # base score
        reasons = []
        tags = []

        # 1. Craft / Category Alignment
        matched_group = None
        for group, words in craft_groups.items():
            spec_matches = any(w in spec for w in words)
            query_matches = any(w in all_text for w in words)
            if spec_matches and query_matches:
                matched_group = group
                break

        if matched_group == "textile":
            score += 44
            reasons.append(f"Mastery in {a.get('craft_specialization')}, ideal for fabric weaving and textile production.")
            tags.append("Handloom Expert")
        elif matched_group == "pottery":
            score += 46
            reasons.append(f"Specialized in {a.get('craft_specialization')} with high-capacity kilns for custom pottery.")
            tags.append("Pottery Master")
        elif matched_group == "block_print":
            score += 43
            reasons.append("Excels in traditional hand-block printing using organic dyes and teakwood blocks.")
            tags.append("Block Printing")
        elif matched_group == "bamboo":
            score += 44
            reasons.append("Experienced in sustainable bamboo & cane joinery, perfect for eco-friendly craft goods.")
            tags.append("Eco Bamboo")
        elif matched_group == "wood":
            score += 45
            reasons.append("Expert woodcarver specializing in solid wood carving and precision joinery.")
            tags.append("Master Woodcarver")
        elif matched_group == "metal":
            score += 44
            reasons.append("Skilled in lost-wax casting, brass molding, and traditional metalcraft.")
            tags.append("Metalcraft Artisan")
        elif any(term in all_text for term in spec.split() if len(term) > 3):
            score += 26
            reasons.append(f"Workshop capabilities in {a.get('craft_specialization')} closely relate to this product.")
            tags.append("Allied Craft")
        else:
            score += 12
            reasons.append(f"Artisan specializing in {a.get('craft_specialization')} with versatile handcrafted batch capability.")
            tags.append("Custom Batch")

        # 2. Material Match
        req_mat = (req.material or "").lower()
        if req_mat:
            if req_mat in spec or req_mat in bio:
                score += 10
                reasons.append(f"Direct expertise working with {req.material}.")
                tags.append(f"{req.material.title()} Specialist")

        # 3. Location / Proximity
        req_loc = (req.delivery_location or "").lower()
        if req_loc and (req_loc in loc or req_loc in state or loc in req_loc or state in req_loc):
            score += 8
            reasons.append(f"Located in {a.get('location')}, offering reduced delivery transit times.")
            tags.append("Nearby Hub")

        # 4. Experience & Rating differentiation
        score += min(8, exp // 3)
        if rating >= 4.8:
            score += 6
            tags.append(f"{rating}★ Top Rated")
        elif rating >= 4.6:
            score += 3

        if verified:
            score += 4
            tags.append("Verified Artisan")

        final_score = min(98, max(40, score))

        scored_items.append({
            "artisan": a,
            "raw_score": final_score,
            "reasons": reasons,
            "tags": tags,
            "exp": exp,
            "rating": rating,
        })

    # Sort descending
    scored_items.sort(key=lambda x: (x["raw_score"], x["rating"], x["exp"]), reverse=True)

    # Ensure no two artisans have the exact same score (guaranteed distinct percentages)
    used_scores = set()
    for idx, item in enumerate(scored_items):
        target_score = item["raw_score"]
        while target_score in used_scores or (idx > 0 and target_score >= scored_items[idx - 1].get("final_score", 999)):
            target_score -= 3
        target_score = max(38, min(98, target_score))
        used_scores.add(target_score)
        item["final_score"] = target_score

        feasibility = "Very High" if target_score >= 85 else ("High" if target_score >= 70 else "Moderate")
        a = item["artisan"]

        ranked.append(
            B2BMatchedArtisan(
                artisan_id=str(a.get("id")),
                artisan_name=str(a.get("name")),
                avatar_url=str(a.get("avatar_url") or ""),
                craft_specialization=str(a.get("craft_specialization") or "Traditional Crafts"),
                location=str(a.get("location") or ""),
                state=str(a.get("state") or ""),
                years_of_experience=item["exp"],
                average_rating=item["rating"],
                total_reviews=int(a.get("total_reviews") or 0),
                is_verified=bool(a.get("is_verified") or False),
                match_score=item["final_score"],
                match_reason=" ".join(item["reasons"]),
                feasibility=feasibility,
                highlight_tags=item["tags"][:3],
            )
        )

    summary = f"Requirement for {req.quantity or 'bulk'} units of '{req.title}'"
    analysis = (
        f"HastKala AI analyzed your requirement for '{req.title}' (quantity: {req.quantity or 'flexible'}, "
        f"deadline: {req.deadline or 'standard'}). Evaluated and ranked {len(ranked)} registered Indian artisans on craft specialization, "
        f"production scale, and regional fulfillment."
    )

    return B2BMatchResponse(
        success=True,
        requirement_summary=summary,
        ai_analysis=analysis,
        suggested_craft=req.category or req.craft_type or "Handcrafted Item",
        estimated_production_time="2 to 4 weeks depending on batch volume",
        matches=ranked,
        total_matches=len(ranked),
        model_used="HastKala AI Engine",
    )


def match_requirement_with_groq(req: B2BRequirementMatchRequest) -> B2BMatchResponse:
    """Main AI Matcher: Uses HastKala AI (via cloud LLM) to intelligently analyze

    the buyer's requirement and match with registered artisans on a real basis.
    """
    artisans = fetch_all_artisans()

    if not settings.GROQ_API_KEY:
        logger.warning("GROQ_API_KEY not configured. Falling back to HastKala AI rule engine.")
        return _local_fallback_match(req, artisans)

    try:
        from groq import Groq

        client = Groq(api_key=settings.GROQ_API_KEY)
    except Exception as e:
        logger.error(f"Failed to initialize Groq client: {e}")
        return _local_fallback_match(req, artisans)

    # Build artisan context for LLM
    artisan_lines = []
    for idx, a in enumerate(artisans, start=1):
        line = (
            f"Artisan #{idx} [ID: {a.get('id')}]: Name: {a.get('name')}, "
            f"Craft: {a.get('craft_specialization')}, Location: {a.get('location')}, {a.get('state')}, "
            f"Experience: {a.get('years_of_experience', 0)} years, Rating: {a.get('average_rating', 0.0)}★, "
            f"Verified: {a.get('is_verified', False)}, "
            f"Bio: {a.get('bio', '')}"
        )
        artisan_lines.append(line)
    artisan_context = "\n".join(artisan_lines)

    # Prepare user requirement string
    req_details = [
        f"Product/Requirement Title: {req.title}",
        f"Category: {req.category or 'Not specified'}",
        f"Craft Type: {req.craft_type or 'Not specified'}",
        f"Material: {req.material or 'Not specified'}",
        f"Quantity Needed: {req.quantity if req.quantity else 'Not specified'}",
        f"Target Deadline: {req.deadline or 'Flexible'}",
        f"Budget Range: INR {req.budget_min or 0} - {req.budget_max or 'Open'} per piece",
        f"Delivery Location: {req.delivery_location or 'India'}",
        f"Customization Details: {req.customization or 'Standard handcrafted'}",
        f"Description: {req.description or 'No extra description'}",
    ]
    req_context = "\n".join(req_details)

    system_prompt = (
        "You are HastKala AI, the proprietary intelligent Indian Handicraft & B2B Sourcing Matchmaker. "
        "A business buyer has posted a custom handicraft requirement. "
        "Your job is to deeply analyze the requirement and evaluate every registered artisan in the database to determine: "
        "1. Who can best fulfill this requirement. "
        "2. Match score (0 to 100) based on craft specialization match, materials, experience, capacity, and location. "
        "CRITICAL REQUIREMENT: Assign REALISTIC, DIVERSE, and DISTINCT match scores (e.g. 95%, 88%, 79%, 67%, 52%). "
        "NEVER give the same percentage to multiple artisans. Every artisan must have a distinct, differentiated score reflecting their true degree of fit. "
        "3. Clear, compelling match reason explaining specifically why this artisan can make this product and meet deadlines. "
        "4. Feasibility ('Very High', 'High', 'Moderate'). "
        "5. 2-3 short highlight tags for the buyer. "
        "6. Provide a 2-3 sentence overall requirement analysis and estimated production lead time. "
        "Always identify yourself as 'HastKala AI'. Return ONLY valid JSON matching the schema."
    )

    user_prompt = f"""
BUYER REQUIREMENT:
{req_context}

REGISTERED ARTISANS IN PLATFORM:
{artisan_context}

OUTPUT FORMAT (JSON ONLY, NO MARKDOWN OUTSIDE JSON):
{{
  "requirement_summary": "Short 1-line summary of what is needed",
  "ai_analysis": "2-3 sentences analyzing craft technique, feasibility for quantity and deadline, and key artisan capabilities needed",
  "suggested_craft": "Primary craft category / technique",
  "estimated_production_time": "Estimated production timeframe, e.g. 2-3 weeks",
  "matches": [
    {{
      "artisan_id": "Exact ID from artisan list",
      "artisan_name": "Artisan Name",
      "match_score": 95,
      "match_reason": "Specific explanation of why this artisan matches (craft match, experience, scale, location)",
      "feasibility": "Very High",
      "highlight_tags": ["Master Potter", "Bulk Order Ready", "Kiln Facility"]
    }}
  ]
}}
Rank the matches array strictly from highest match_score to lowest. Ensure EVERY artisan has a DIFFERENT, unique match_score.
"""

    active_model = settings.GROQ_MODEL
    if not active_model or active_model.startswith("groq/"):
        active_model = "qwen/qwen3.8-27b"

    candidate_models = [active_model]
    for m in ["qwen/qwen3.8-27b", "openai/gpt-oss-120b", "openai/gpt-oss-20b", "groq/compound"]:
        if m not in candidate_models:
            candidate_models.append(m)

    for model_name in candidate_models:
        try:
            logger.info(f"Querying cloud LLM '{model_name}' for B2B artisan matching...")
            try:
                chat = client.chat.completions.create(
                    model=model_name,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt},
                    ],
                    response_format={"type": "json_object"},
                    max_tokens=3000,
                    temperature=0.2,
                    timeout=25.0,
                )
            except Exception as jerr:
                logger.info(f"Retrying '{model_name}' without response_format constraint: {jerr}")
                chat = client.chat.completions.create(
                    model=model_name,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt},
                    ],
                    max_tokens=3000,
                    temperature=0.2,
                    timeout=25.0,
                )

            raw_content = chat.choices[0].message.content or ""
            logger.info(f"HastKala AI engine '{model_name}' responded ({len(raw_content)} chars)")

            cleaned = _clean_json_str(raw_content)
            data = None
            try:
                data = json.loads(cleaned)
            except Exception as parse_err:
                logger.warning(f"Standard JSON parse failed ({parse_err}). Attempting repair...")
                if "matches" in cleaned and not cleaned.rstrip().endswith("}"):
                    repaired = cleaned.rstrip().rstrip(",")
                    if not repaired.endswith("]"):
                        repaired += "]}"
                    else:
                        repaired += "}"
                    try:
                        data = json.loads(repaired)
                    except Exception:
                        pass
                if not data:
                    raise parse_err

            if isinstance(data, dict) and "matches" in data:
                raw_matches = data.get("matches", [])
                matched_artisans: List[B2BMatchedArtisan] = []

                # Build artisan lookup map
                artisan_map = {str(a.get("id")): a for a in artisans}
                artisan_name_map = {str(a.get("name")).strip().lower(): a for a in artisans}

                used_scores = set()

                for item in raw_matches:
                    aid = str(item.get("artisan_id", "")).strip()
                    aname = str(item.get("artisan_name", "")).strip()

                    # Find original artisan data
                    orig = artisan_map.get(aid) or artisan_name_map.get(aname.lower())
                    if not orig:
                        continue

                    score = int(item.get("match_score", 50))
                    score = min(99, max(5, score))

                    # Ensure distinct percentages (no duplicates)
                    while score in used_scores:
                        score = max(5, score - 2)
                    used_scores.add(score)

                    reason = item.get("match_reason") or f"Specializes in {orig.get('craft_specialization')}."
                    feasibility = item.get("feasibility") or ("Very High" if score >= 85 else ("High" if score >= 70 else "Moderate"))
                    tags = item.get("highlight_tags") or []
                    if isinstance(tags, list):
                        tags = [str(t) for t in tags[:3]]
                    else:
                        tags = ["Handcrafted", "Custom Orders"]

                    matched_artisans.append(
                        B2BMatchedArtisan(
                            artisan_id=str(orig.get("id")),
                            artisan_name=str(orig.get("name")),
                            avatar_url=str(orig.get("avatar_url") or ""),
                            craft_specialization=str(orig.get("craft_specialization") or ""),
                            location=str(orig.get("location") or ""),
                            state=str(orig.get("state") or ""),
                            years_of_experience=int(orig.get("years_of_experience") or 0),
                            average_rating=float(orig.get("average_rating") or 0.0),
                            total_reviews=int(orig.get("total_reviews") or 0),
                            is_verified=bool(orig.get("is_verified") or False),
                            match_score=score,
                            match_reason=str(reason),
                            feasibility=str(feasibility),
                            highlight_tags=tags,
                        )
                    )

                if matched_artisans:
                    matched_artisans.sort(key=lambda x: x.match_score, reverse=True)
                    return B2BMatchResponse(
                        success=True,
                        requirement_summary=data.get("requirement_summary") or f"Requirement for '{req.title}'",
                        ai_analysis=data.get("ai_analysis")
                        or f"HastKala AI matched {len(matched_artisans)} artisans suited for this craft and deadline.",
                        suggested_craft=data.get("suggested_craft")
                        or req.category
                        or req.craft_type
                        or "Indian Handicrafts",
                        estimated_production_time=data.get("estimated_production_time") or "2-3 weeks",
                        matches=matched_artisans,
                        total_matches=len(matched_artisans),
                        model_used="HastKala AI Engine",
                    )
        except Exception as e:
            logger.warning(f"HastKala AI match attempt with {model_name} failed: {e}")
            continue

    logger.warning("All LLM models failed or timed out. Falling back to HastKala AI rule engine.")
    return _local_fallback_match(req, artisans)
