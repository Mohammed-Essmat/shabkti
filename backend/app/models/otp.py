from beanie import Document
from pydantic import Field
from datetime import datetime, timedelta
from typing import Optional
from pymongo import IndexModel, ASCENDING

class OTP(Document):
    identifier: str
    code: str
    type: str
    purpose: str = "register"
    expires_at: datetime
    verified: bool = False
    temp_user_data: Optional[dict] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "otp_codes"
        indexes = [
            IndexModel([("identifier", ASCENDING)]),
            IndexModel([("expires_at", ASCENDING)], expireAfterSeconds=0),
        ]

    @classmethod
    def create_new(cls, identifier: str, code: str, otp_type: str, purpose: str = "register", temp_user_data: Optional[dict] = None):
        return cls(
            identifier=identifier,
            code=code,
            type=otp_type,
            purpose=purpose,
            expires_at=datetime.utcnow() + timedelta(minutes=10),
            temp_user_data=temp_user_data
        )

    def is_expired(self) -> bool:
        return datetime.utcnow() > self.expires_at
