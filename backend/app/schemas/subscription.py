from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CreateSubscriptionRequest(BaseModel):
    package_id: str
    replace_existing: bool = False

class SubscriptionResponse(BaseModel):
    id: str
    user_id: str
    package_id: str
    package_name: Optional[str] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    total_data_gb: float
    used_data_gb: float
    remaining_data_gb: float
    status: str
    hotspot_username: Optional[str] = None
    hotspot_password: Optional[str] = None
    beneficiary_ids: List[str]
    created_at: datetime

class UsageStatsResponse(BaseModel):
    total_gb: float
    used_gb: float
    remaining_gb: float
    percentage_used: float
    days_remaining: Optional[int] = None
    status: str

class PaymentInfoResponse(BaseModel):
    payment_id: str
    subscription_id: str
    amount: float
    status: str
    vodafone_cash_number: str = "01234567890"
    instapay_address: str = "internet.packages@instapay"
