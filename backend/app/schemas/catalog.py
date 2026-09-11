from typing import Optional

from pydantic import BaseModel, field_validator


class TranscriptRequest(BaseModel):
    transcript: str

    @field_validator("transcript")
    @classmethod
    def transcript_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Transcript cannot be empty")
        return v.strip()


class ProductDetails(BaseModel):
    product_name: Optional[str] = None
    category: Optional[str] = None
    material: Optional[str] = None
    craft: Optional[str] = None
    color: Optional[str] = None
    size: Optional[str] = None
    weight: Optional[str] = None
    quantity: Optional[str] = None
    production_capacity: Optional[str] = None
    making_time: Optional[str] = None
    making_process: Optional[str] = None
    location: Optional[str] = None
    price: Optional[str] = None
    craft_story: Optional[str] = None
    artisan_intro: Optional[str] = None


class ExtractionResponse(BaseModel):
    success: bool
    data: Optional[ProductDetails] = None
    error: Optional[str] = None
