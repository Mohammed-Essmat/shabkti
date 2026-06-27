from beanie import Document
from pydantic import Field
from typing import List

class Package(Document):
    name: str
    type: str
    data_amount_gb: float
    price: float
    validity_days: int
    description: str
    features: List[str] = Field(default_factory=list)
    is_active: bool = True

    class Settings:
        name = "packages"
