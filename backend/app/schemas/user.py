from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class UserResponse(BaseModel):
    id: str
    name: str
    email: EmailStr
    phone: str
    profile_picture_url: Optional[str] = None
    role: str
    is_verified: bool
    created_at: datetime

class UpdateProfileRequest(BaseModel):
    name: Optional[str] = None

class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str
    confirm_password: str
