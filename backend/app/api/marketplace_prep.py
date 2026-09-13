from fastapi import APIRouter, HTTPException

from ..schemas.marketplace_prep import MarketplaceListingRequest, MarketplaceListingResponse
from ..ai.marketplace_prep import prepare_listing

router = APIRouter(prefix="/api/ai", tags=["marketplace-prep"])


@router.post("/prepare-marketplace-listing", response_model=MarketplaceListingResponse)
async def prepare_marketplace_listing(req: MarketplaceListingRequest):
    """AI-powered marketplace listing preparation."""
    data = {
        "product_name": req.product_name,
        "description": req.description,
        "material": req.material,
        "craft_type": req.craft_type,
        "category": req.category,
        "price": req.price,
        "color": req.color,
        "size": req.size,
        "weight": req.weight,
        "dimensions": req.dimensions,
        "marketplace": req.marketplace,
        "existing_bullet_points": req.existing_bullet_points,
        "existing_keywords": req.existing_keywords,
    }

    try:
        listing = await prepare_listing(data)
        if listing:
            return MarketplaceListingResponse(success=True, listing=listing)
        return MarketplaceListingResponse(
            success=False, error="Could not generate listing. Please try again."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
