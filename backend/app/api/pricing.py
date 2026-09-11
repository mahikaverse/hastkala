import logging

from fastapi import APIRouter, HTTPException

from app.ai.price_assistant import suggest_price
from app.schemas.pricing import PriceSuggestionRequest, PriceSuggestionResponse

logger = logging.getLogger("hastkala.api.pricing")

router = APIRouter(prefix="/api/ai", tags=["AI Pricing"])


@router.post("/suggest-price", response_model=PriceSuggestionResponse)
async def get_price_suggestion(req: PriceSuggestionRequest):
    logger.info(
        f"Suggest price request: item='{req.product_name}', craft='{req.craft}', expected={req.artisan_expected_price}"
    )

    try:
        response = suggest_price(req)
        return response
    except Exception as e:
        logger.error(f"Error suggesting price: {e}", exc_info=True)
        # Even on unexpected error, fallback safely with artisan expected price
        expected = req.artisan_expected_price
        return PriceSuggestionResponse(
            success=False,
            artisan_expected_price=expected,
            market_min=expected,
            market_max=expected,
            recommended_min=expected,
            recommended_max=expected,
            suggested_price=expected,
            comparables_found=0,
            reason="We couldn't reach market services right now. You can continue with your price.",
            sources=[],
            error=str(e),
        )
