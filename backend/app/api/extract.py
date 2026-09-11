import logging

from fastapi import APIRouter, HTTPException

from app.ai.catalog_extractor import extract_product_details
from app.schemas.catalog import ExtractionResponse, TranscriptRequest

logger = logging.getLogger("hastkala.ai.extract")

router = APIRouter(prefix="/api/ai", tags=["AI"])


@router.post("/extract-product-details", response_model=ExtractionResponse)
async def extract_details(req: TranscriptRequest):
    logger.info(f"Extract request: {len(req.transcript)} chars")

    try:
        data = extract_product_details(req.transcript)
        return ExtractionResponse(success=True, data=data)
    except RuntimeError as e:
        logger.error(f"Extraction failed: {e}")
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        logger.error(f"Unexpected extraction error: {e}")
        raise HTTPException(status_code=500, detail=f"Extraction failed: {e}")
