from typing import Optional
from pydantic import BaseModel


class MarketingMessageRequest(BaseModel):
    product_name: str
    description: Optional[str] = None
    material: Optional[str] = None
    craft_type: Optional[str] = None
    price: Optional[float] = None
    category: Optional[str] = None
    tags: Optional[list[str]] = None
    language: str = "en"  # "en" or "hi"
    artisan_name: Optional[str] = None
    location: Optional[str] = None
    craft_story: Optional[str] = None
    making_time: Optional[str] = None


class MarketingMessageResponse(BaseModel):
    success: bool
    message: Optional[str] = None
    error: Optional[str] = None
