import logging
from typing import Any, Dict

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.ai.catalog_extractor import (
    extract_product_details,
    extract_step1_product_details,
    extract_step2_quantity_details,
    extract_step3_story_details,
)
from app.schemas.catalog import ExtractionResponse, TranscriptRequest

logger = logging.getLogger("hastkala.ai.extract")

router = APIRouter(prefix="/api/ai", tags=["AI"])


class StepExtractionResponse(BaseModel):
    success: bool
    data: Dict[str, Any]
    error: str = None


@router.post("/extract-product-details", response_model=ExtractionResponse)
async def extract_details(req: TranscriptRequest):
    """Extract complete product catalog details."""
    logger.info(f"Full extract request: {len(req.transcript)} chars")
    try:
        data = extract_product_details(req.transcript)
        return ExtractionResponse(success=True, data=data)
    except Exception as e:
        logger.error(f"Extraction error: {e}")
        raise HTTPException(status_code=500, detail=f"Extraction failed: {e}")


@router.post("/extract-step1", response_model=StepExtractionResponse)
async def extract_step1(req: TranscriptRequest):
    """Step 1: Extract product name, category, material, craft, color, size, weight."""
    logger.info(f"Extract Step 1 request: {len(req.transcript)} chars")
    try:
        data = extract_step1_product_details(req.transcript)
        return StepExtractionResponse(success=True, data=data)
    except Exception as e:
        logger.error(f"Step 1 extraction error: {e}")
        return StepExtractionResponse(success=False, data={}, error=str(e))


@router.post("/extract-step2", response_model=StepExtractionResponse)
async def extract_step2(req: TranscriptRequest):
    """Step 2: Extract quantity, capacity, making time, making process."""
    logger.info(f"Extract Step 2 request: {len(req.transcript)} chars")
    try:
        data = extract_step2_quantity_details(req.transcript)
        return StepExtractionResponse(success=True, data=data)
    except Exception as e:
        logger.error(f"Step 2 extraction error: {e}")
        return StepExtractionResponse(success=False, data={}, error=str(e))


@router.post("/extract-step3", response_model=StepExtractionResponse)
async def extract_step3(req: TranscriptRequest):
    """Step 3: Extract craft origin story, location, artisan heritage."""
    logger.info(f"Extract Step 3 request: {len(req.transcript)} chars")
    try:
        data = extract_step3_story_details(req.transcript)
        return StepExtractionResponse(success=True, data=data)
    except Exception as e:
        logger.error(f"Step 3 extraction error: {e}")
        return StepExtractionResponse(success=False, data={}, error=str(e))
