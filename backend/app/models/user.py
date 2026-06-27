from beanie import Document
from pydantic import EmailStr, Field
from datetime import datetime
from typing import Optional
from pymongo import IndexModel, ASCENDING

class User(Document):
    name: str
    email: EmailStr
    phone: str
    password_hash: str
    profile_picture_url: Optional[str] = None
    role: str = "user"
    parent_subscription_id: Optional[str] = None
    is_verified: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "users"
        indexes = [
            IndexModel([("email", ASCENDING)], unique=True),
            IndexModel([("phone", ASCENDING)], unique=True),
        ]
