from typing import List, Optional
from pydantic import BaseModel, Field


class PriceSuggestionRequest(BaseModel):
    product_name: Optional[str] = None
    category: Optional[str] = None
    material: Optional[str] = None
    craft: Optional[str] = None
    color: Optional[str] = None
    size: Optional[str] = None
    making_time: Optional[str] = None
    location: Optional[str] = None
    raw_material_cost: Optional[float] = None
    artisan_expected_price: int = Field(..., gt=0, description="Artisan expected selling price in INR")


class ComparableProduct(BaseModel):
    title: str
    price: int
    source: Optional[str] = None
    url: Optional[str] = None


class PriceSuggestionResponse(BaseModel):
    success: bool = True
    artisan_expected_price: int
    market_min: int
    market_max: int
    recommended_min: int
    recommended_max: int
    suggested_price: int
    comparables_found: int
    reason: str
    sources: List[ComparableProduct] = []
    error: Optional[str] = None
