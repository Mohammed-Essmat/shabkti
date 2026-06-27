import os
import uuid
import cloudinary
import cloudinary.uploader
from app.config import settings
from typing import Optional

UPLOADS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "uploads")

class StorageService:
    @staticmethod
    def _init_cloudinary():
        if settings.CLOUDINARY_CLOUD_NAME:
            cloudinary.config(
                cloud_name=settings.CLOUDINARY_CLOUD_NAME,
                api_key=settings.CLOUDINARY_API_KEY,
                api_secret=settings.CLOUDINARY_API_SECRET
            )

    @staticmethod
    async def upload(file_bytes: bytes, folder: str) -> Optional[str]:
        if settings.CLOUDINARY_CLOUD_NAME:
            try:
                StorageService._init_cloudinary()
                result = cloudinary.uploader.upload(file_bytes, folder=folder, resource_type="image")
                return result.get("secure_url")
            except Exception as e:
                print(f"Cloudinary upload error: {e}")
                return None

        try:
            safe_folder = os.path.basename(folder.replace("..", "").strip("/\\"))
            folder_path = os.path.join(UPLOADS_DIR, safe_folder)
            os.makedirs(folder_path, exist_ok=True)
            filename = f"{uuid.uuid4().hex}.jpg"
            filepath = os.path.join(folder_path, filename)
            with open(filepath, "wb") as f:
                f.write(file_bytes)
            return f"/uploads/{safe_folder}/{filename}"
        except Exception as e:
            print(f"Local upload error: {e}")
            return None
