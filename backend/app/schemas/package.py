from pydantic import BaseModel
from typing import List

class PackageResponse(BaseModel):
    id: str
    name: str
    type: str
    data_amount_gb: float
    price: float
    validity_days: int
    description: str
    features: List[str]
    is_active: bool
