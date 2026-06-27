from beanie import Document
from pydantic import Field
from datetime import datetime
from typing import List, Optional
from pymongo import IndexModel, ASCENDING

class Subscription(Document):
    user_id: str
    package_id: str
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    total_data_gb: float
    used_data_gb: float = 0.0
    remaining_data_gb: float
    status: str = "pending"
    hotspot_username: Optional[str] = None
    hotspot_password: Optional[str] = None
    beneficiary_ids: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "subscriptions"
        indexes = [
            IndexModel([("user_id", ASCENDING)]),
            IndexModel([("status", ASCENDING)]),
        ]
