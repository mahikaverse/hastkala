import logging
from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from app.ai.b2b_matcher import match_requirement_with_groq
from app.core.supabase import get_supabase
from app.schemas.b2b import B2BMatchResponse, B2BRequirementMatchRequest

logger = logging.getLogger("hastkala.api.b2b")

router = APIRouter(prefix="/api/b2b", tags=["B2B AI Matcher"])


@router.post("/match-artisans", response_model=B2BMatchResponse)
async def match_artisans_endpoint(req: B2BRequirementMatchRequest):
    """Analyze a B2B requirement using Groq AI and match with best-suited artisans.

    Evaluates craft specialization, materials, quantity feasibility, deadline, and location.
    """
    logger.info(
        f"B2B match request: title='{req.title}', qty={req.quantity}, deadline='{req.deadline}', "
        f"loc='{req.delivery_location}'"
    )
    try:
        response = match_requirement_with_groq(req)
        return response
    except Exception as e:
        logger.error(f"Error matching artisans with Groq: {e}", exc_info=True)
        return B2BMatchResponse(
            success=False,
            requirement_summary=f"Requirement for {req.title}",
            ai_analysis="Could not complete AI analysis at this moment.",
            matches=[],
            total_matches=0,
            error=str(e),
        )


@router.get("/match-requirement/{requirement_id}", response_model=B2BMatchResponse)
async def match_existing_requirement(requirement_id: str):
    """Fetch an existing posted requirement by ID from Supabase and run Groq AI matching."""
    try:
        supabase = get_supabase()
        res = (
            supabase.table("b2b_requirements")
            .select("*")
            .eq("id", requirement_id)
            .single()
            .execute()
        )
        if not res.data:
            raise HTTPException(status_code=404, detail="Requirement not found")

        r = res.data
        req = B2BRequirementMatchRequest(
            requirement_id=requirement_id,
            title=r.get("title") or "Handicraft Requirement",
            category=r.get("category"),
            craft_type=r.get("craft_type"),
            material=r.get("material"),
            quantity=r.get("quantity"),
            budget_min=float(r["budget_min"]) if r.get("budget_min") is not None else None,
            budget_max=float(r["budget_max"]) if r.get("budget_max") is not None else None,
            delivery_location=r.get("delivery_location"),
            deadline=str(r.get("deadline")) if r.get("deadline") else None,
            customization=r.get("customization"),
            description=r.get("description"),
        )
        return match_requirement_with_groq(req)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error matching existing requirement {requirement_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
