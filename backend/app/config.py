from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    MONGODB_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    CLOUDINARY_CLOUD_NAME: Optional[str] = None
    CLOUDINARY_API_KEY: Optional[str] = None
    CLOUDINARY_API_SECRET: Optional[str] = None
    TWILIO_ACCOUNT_SID: Optional[str] = None
    TWILIO_AUTH_TOKEN: Optional[str] = None
    TWILIO_PHONE_NUMBER: Optional[str] = None
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    PAYMOB_API_KEY: Optional[str] = None
    PAYMOB_INTEGRATION_ID: Optional[str] = None
    PAYMOB_IFRAME_ID: Optional[str] = None
    MIKROTIK_HOST: Optional[str] = None
    MIKROTIK_PORT: int = 8728
    MIKROTIK_USER: Optional[str] = None
    MIKROTIK_PASSWORD: Optional[str] = None
    ADMIN_USERNAME: str = "admin"
    ADMIN_PASSWORD: str = "admin123"
    APP_NAME: str = "Internet Packages"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
