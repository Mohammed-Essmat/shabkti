from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class AddBeneficiaryRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(..., pattern=r"^\+?[1-9]\d{1,14}$")
    password: str = Field(..., min_length=6)

class UpdateBeneficiaryRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)

class BeneficiaryResponse(BaseModel):
    id: str
    name: str
    email: EmailStr
    phone: str
    profile_picture_url: Optional[str] = None
    created_at: datetime
