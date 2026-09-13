import logging

from fastapi import APIRouter, HTTPException

from app.ai.marketing import generate_marketing_message
from app.schemas.marketing import MarketingMessageRequest, MarketingMessageResponse

logger = logging.getLogger("hastkala.api.marketing")

router = APIRouter(prefix="/api/ai", tags=["AI Marketing"])


@router.post("/generate-marketing-message", response_model=MarketingMessageResponse)
async def create_marketing_message(req: MarketingMessageRequest):
    """Generate an AI marketing message for a product using verified product data only."""
    logger.info(f"Marketing message request: product={req.product_name}, lang={req.language}")
    try:
        data = req.model_dump()
        message = generate_marketing_message(data, language=req.language)
        if message:
            return MarketingMessageResponse(success=True, message=message)
        return MarketingMessageResponse(
            success=False,
            error="Could not generate marketing message. Please try again.",
        )
    except Exception as e:
        logger.error(f"Marketing generation error: {e}")
        raise HTTPException(status_code=500, detail=f"Marketing generation failed: {e}")
