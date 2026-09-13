from pydantic import BaseModel
from typing import List, Optional


class MarketplaceListingRequest(BaseModel):
    product_name: str
    description: Optional[str] = None
    material: Optional[str] = None
    craft_type: Optional[str] = None
    category: Optional[str] = None
    price: float
    color: Optional[str] = None
    size: Optional[str] = None
    weight: Optional[str] = None
    dimensions: Optional[str] = None
    marketplace: str  # amazon, flipkart, blinkit, other
    existing_bullet_points: List[str] = []
    existing_keywords: List[str] = []


class MarketplaceListingResponse(BaseModel):
    success: bool
    listing: Optional[dict] = None
    error: Optional[str] = None
