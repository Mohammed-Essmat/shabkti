from beanie import Document
from pydantic import Field
from datetime import datetime
from typing import Optional
from pymongo import IndexModel, ASCENDING

class Payment(Document):
    subscription_id: str
    user_id: str
    amount: float
    payment_method: str = "pending"
    payment_proof_url: Optional[str] = None
    paymob_transaction_id: Optional[str] = None
    status: str = "pending"
    verified_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "payments"
        indexes = [
            IndexModel([("subscription_id", ASCENDING)]),
            IndexModel([("user_id", ASCENDING)]),
            IndexModel([("status", ASCENDING)]),
        ]
