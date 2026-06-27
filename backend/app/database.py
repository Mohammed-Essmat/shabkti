from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from app.config import settings
from app.models.user import User
from app.models.package import Package
from app.models.subscription import Subscription
from app.models.payment import Payment
from app.models.otp import OTP

async def init_db():
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    database = client.get_default_database()
    await init_beanie(
        database=database,
        document_models=[User, Package, Subscription, Payment, OTP]
    )
    print("✅ Database initialized successfully")
