import certifi
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from app.config import settings
from app.models.user import User
from app.models.package import Package
from app.models.subscription import Subscription
from app.models.payment import Payment
from app.models.otp import OTP

async def init_db():
    params = {
        "serverSelectionTimeoutMS": 10000,
        "connectTimeoutMS": 10000,
    }
    if settings.MONGODB_URL.startswith("mongodb+srv"):
        params["tlsCAFile"] = certifi.where()

    client = AsyncIOMotorClient(settings.MONGODB_URL, **params)
    database = client.get_default_database()
    await init_beanie(
        database=database,
        document_models=[User, Package, Subscription, Payment, OTP]
    )
    print("Database initialized successfully")
