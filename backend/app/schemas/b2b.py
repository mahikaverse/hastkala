from typing import List, Optional
from pydantic import BaseModel, Field


class B2BRequirementMatchRequest(BaseModel):
    title: str = Field(..., description="Requirement title (e.g., Handwoven Silk Dupattas)")
    category: Optional[str] = Field(None, description="Craft category (e.g., Textiles & Handloom)")
    craft_type: Optional[str] = Field(None, description="Specific craft type (e.g., Banarasi, Blue Pottery)")
    material: Optional[str] = Field(None, description="Materials required (e.g., Pure Silk, Terracotta clay)")
    quantity: Optional[int] = Field(None, description="Required quantity in pieces")
    budget_min: Optional[float] = Field(None, description="Minimum budget per piece in INR")
    budget_max: Optional[float] = Field(None, description="Maximum budget per piece in INR")
    delivery_location: Optional[str] = Field(None, description="Target delivery city or state")
    deadline: Optional[str] = Field(None, description="Deadline date or timeframe")
    customization: Optional[str] = Field(None, description="Customization requirements (branding, colors, sizes)")
    description: Optional[str] = Field(None, description="Detailed description of what is needed")
    requirement_id: Optional[str] = Field(None, description="Optional ID if matching an existing posted requirement")


class B2BMatchedArtisan(BaseModel):
    artisan_id: str
    artisan_name: str
    avatar_url: Optional[str] = ""
    craft_specialization: str
    location: str
    state: Optional[str] = ""
    years_of_experience: int = 0
    average_rating: float = 0.0
    total_reviews: int = 0
    is_verified: bool = False
    match_score: int = Field(..., description="Match percentage from 0 to 100")
    match_reason: str = Field(..., description="AI explanation of why this artisan is suited")
    feasibility: str = Field("High", description="Production & deadline feasibility: Very High, High, Moderate")
    highlight_tags: List[str] = Field(default_factory=list, description="Key badges e.g. ['Master Weaver', 'Bulk Ready']")


class B2BMatchResponse(BaseModel):
    success: bool = True
    requirement_summary: str = ""
    ai_analysis: str = ""
    suggested_craft: str = ""
    estimated_production_time: Optional[str] = None
    matches: List[B2BMatchedArtisan] = Field(default_factory=list)
    total_matches: int = 0
    model_used: Optional[str] = None
    error: Optional[str] = None
