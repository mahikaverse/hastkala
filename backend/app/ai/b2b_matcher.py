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
    """Extract JSON object from markdown blocks or raw text."""
    text = text.strip()
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if match:
        return match.group(0)
    return text


def _local_fallback_match(
    req: B2BRequirementMatchRequest, artisans: List[Dict[str, Any]]
) -> B2BMatchResponse:
    """Deterministic, keyword-based artisan matcher used when Groq is unavailable."""
    keywords = [
        (req.title or "").lower(),
        (req.category or "").lower(),
        (req.craft_type or "").lower(),
        (req.material or "").lower(),
        (req.description or "").lower(),
    ]
    all_text = " ".join(keywords)

    ranked: List[B2BMatchedArtisan] = []

    for a in artisans:
        score = 45  # base score
        reasons = []
        tags = []

        spec = (a.get("craft_specialization") or "").lower()
        bio = (a.get("bio") or "").lower()
        loc = (a.get("location") or "").lower()
        state = (a.get("state") or "").lower()
        exp = int(a.get("years_of_experience") or 0)
        rating = float(a.get("average_rating") or 0.0)

        # Craft match
        if any(w in spec for w in ["silk", "handloom", "textile", "saree", "dupatta", "weave", "cotton"]) and any(
            w in all_text for w in ["silk", "handloom", "textile", "saree", "dupatta", "fabric", "cotton", "cloth", "dress"]
        ):
            score += 40
            reasons.append(f"Specialist in {a.get('craft_specialization')}, well suited for fabric & weaving requirements.")
            tags.append("Handloom Expert")
        elif any(w in spec for w in ["pottery", "ceramic", "terracotta", "clay", "blue pottery"]) and any(
            w in all_text for w in ["pottery", "ceramic", "terracotta", "clay", "cup", "kullad", "plate", "vase", "diya"]
        ):
            score += 40
            reasons.append(f"Mastery in {a.get('craft_specialization')} with established kiln and firing capabilities.")
            tags.append("Pottery Master")
        elif any(w in spec for w in ["block", "print"]) and any(
            w in all_text for w in ["block", "print", "fabric", "cotton", "pattern", "bag", "dupatta"]
        ):
            score += 38
            reasons.append(f"Excels in authentic wooden block printing with natural and organic dyes.")
            tags.append("Block Print Specialist")
        elif any(w in spec for w in ["bamboo", "cane"]) and any(
            w in all_text for w in ["bamboo", "cane", "basket", "lamp", "wood", "grass", "eco"]
        ):
            score += 40
            reasons.append("Experienced in sustainable bamboo weaving and eco-friendly handicrafts.")
            tags.append("Eco Bamboo Craftsman")
        elif any(w in spec for w in ["wood", "carving"]) and any(
            w in all_text for w in ["wood", "carving", "box", "sculpture", "furniture", "teak", "sheesham"]
        ):
            score += 40
            reasons.append(f"Specializes in fine woodcraft and custom hand-carved articles.")
            tags.append("Master Woodcarver")
        elif spec and any(term in all_text for term in spec.split()):
            score += 25
            reasons.append(f"Skills in {a.get('craft_specialization')} align with this product.")

        # Location proximity
        req_loc = (req.delivery_location or "").lower()
        if req_loc and (req_loc in loc or req_loc in state or loc in req_loc):
            score += 10
            reasons.append(f"Located near {a.get('location')}, offering reduced shipping lead times.")
            tags.append("Regional Hub")

        # Experience & Rating
        if exp >= 15:
            score += 6
            tags.append(f"{exp}+ Yrs Experience")
        if rating >= 4.7:
            score += 5
            tags.append("Top Rated 4.7★+")

        if a.get("is_verified"):
            tags.append("Verified Artisan")

        # Cap score between 30 and 99
        final_score = min(99, max(35, score))

        if not reasons:
            reasons.append(f"Artisan with expertise in {a.get('craft_specialization')} available for custom batch production.")

        if not tags:
            tags = ["Custom Orders", "Authentic Craft"]

        feasibility = "Very High" if final_score >= 80 else ("High" if final_score >= 60 else "Moderate")

        ranked.append(
            B2BMatchedArtisan(
                artisan_id=str(a.get("id")),
                artisan_name=str(a.get("name")),
                avatar_url=str(a.get("avatar_url") or ""),
                craft_specialization=str(a.get("craft_specialization") or "Traditional Crafts"),
                location=str(a.get("location") or ""),
                state=str(a.get("state") or ""),
                years_of_experience=exp,
                average_rating=rating,
                total_reviews=int(a.get("total_reviews") or 0),
                is_verified=bool(a.get("is_verified") or False),
                match_score=final_score,
                match_reason=" ".join(reasons),
                feasibility=feasibility,
                highlight_tags=tags[:3],
            )
        )

    # Sort descending by match score
    ranked.sort(key=lambda x: x.match_score, reverse=True)

    summary = f"Requirement for {req.quantity or 'bulk'} units of '{req.title}'"
    analysis = (
        f"Analyzed requirement '{req.title}' (quantity: {req.quantity or 'flexible'}, "
        f"deadline: {req.deadline or 'standard'}). Matched with {len(ranked)} active Indian handicraft artisans "
        f"specializing in matching craft traditions."
    )

    return B2BMatchResponse(
        success=True,
        requirement_summary=summary,
        ai_analysis=analysis,
        suggested_craft=req.category or req.craft_type or "Handcrafted Item",
        estimated_production_time="2 to 4 weeks depending on batch volume",
        matches=ranked,
        total_matches=len(ranked),
        model_used="local-rule-engine",
    )


def match_requirement_with_groq(req: B2BRequirementMatchRequest) -> B2BMatchResponse:
    """Main AI Matcher: Uses Groq LLM to intelligently analyze the buyer's requirement

    (title, quantity, deadline, budget, customization, location) and match with registered artisans.
    """
    artisans = fetch_all_artisans()

    if not settings.GROQ_API_KEY:
        logger.warning("GROQ_API_KEY not configured. Falling back to rule-based matcher.")
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
        f"Quantity Needed (kitna chahiye): {req.quantity if req.quantity else 'Not specified'}",
        f"Target Deadline (kab tak chahiye): {req.deadline or 'Flexible'}",
        f"Budget Range: INR {req.budget_min or 0} - {req.budget_max or 'Open'} per piece",
        f"Delivery Location: {req.delivery_location or 'India'}",
        f"Customization Details: {req.customization or 'Standard handcrafted'}",
        f"Description: {req.description or 'No extra description'}",
    ]
    req_context = "\n".join(req_details)

    system_prompt = (
        "You are an expert Indian Handicraft & B2B Sourcing Matchmaker for HastKala. "
        "A business buyer has posted a custom handicraft requirement (kya chahiye, kitna chahiye, kab tak chahiye, budget). "
        "Your job is to deeply analyze the requirement and evaluate every registered artisan in the database to determine: "
        "1. Who can best fulfill this requirement ('yeh yeh artisan hai yeh kar sakte haii'). "
        "2. Match score (0 to 100) based on craft specialization match, materials, experience, capacity, and location. "
        "3. Clear, compelling match reason in English (or natural Indian English) explaining specifically why this artisan can make this product and meet deadlines. "
        "4. Feasibility ('Very High', 'High', 'Moderate'). "
        "5. 2-3 short highlight tags for the buyer. "
        "6. Provide a 2-3 sentence overall requirement analysis and estimated production lead time. "
        "Return ONLY a valid JSON object matching the required schema."
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
      "highlight_tags": ["Master Weaver", "Bulk Order Ready", "Varanasi Silk"]
    }}
  ]
}}
Rank the matches array strictly from highest match_score to lowest. Include all relevant artisans who have reasonable capability.
"""

    candidate_models = ["groq/compound-mini", "openai/gpt-oss-20b", "openai/gpt-oss-120b"]

    for model_name in candidate_models:
        try:
            logger.info(f"Querying Groq model '{model_name}' for B2B artisan matching...")
            chat = client.chat.completions.create(
                model=model_name,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                max_tokens=900,
                temperature=0.2,
                timeout=15.0,
            )
            raw_content = chat.choices[0].message.content or ""
            logger.info(f"Groq '{model_name}' responded ({len(raw_content)} chars)")

            cleaned = _clean_json_str(raw_content)
            data = json.loads(cleaned)

            if isinstance(data, dict) and "matches" in data:
                raw_matches = data.get("matches", [])
                matched_artisans: List[B2BMatchedArtisan] = []

                # Build artisan lookup map
                artisan_map = {str(a.get("id")): a for a in artisans}
                artisan_name_map = {str(a.get("name")).strip().lower(): a for a in artisans}

                for item in raw_matches:
                    aid = str(item.get("artisan_id", "")).strip()
                    aname = str(item.get("artisan_name", "")).strip()

                    # Find original artisan data
                    orig = artisan_map.get(aid) or artisan_name_map.get(aname.lower())
                    if not orig:
                        continue

                    score = int(item.get("match_score", 50))
                    # Clamp score
                    score = min(100, max(1, score))

                    reason = item.get("match_reason") or f"Specializes in {orig.get('craft_specialization')}."
                    feasibility = item.get("feasibility") or "High"
                    tags = item.get("highlight_tags") or []
                    if isinstance(tags, list):
                        tags = [str(t) for t in tags[:3]]
                    else:
                        tags = ["Handcrafted", "Custom"]

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
                        or f"AI matched {len(matched_artisans)} artisans suited for this craft and deadline.",
                        suggested_craft=data.get("suggested_craft")
                        or req.category
                        or req.craft_type
                        or "Indian Handicrafts",
                        estimated_production_time=data.get("estimated_production_time") or "2-3 weeks",
                        matches=matched_artisans,
                        total_matches=len(matched_artisans),
                        model_used=model_name,
                    )
        except Exception as e:
            logger.warning(f"Groq match attempt with {model_name} failed: {e}")
            continue

    logger.warning("All Groq models failed or timed out. Falling back to local matcher.")
    return _local_fallback_match(req, artisans)
