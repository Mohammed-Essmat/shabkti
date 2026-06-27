from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from app.schemas.user import UserResponse, UpdateProfileRequest, ChangePasswordRequest
from app.models.user import User
from app.utils.dependencies import get_current_verified_user
from app.utils.security import verify_password, hash_password
from app.services.storage_service import StorageService
from datetime import datetime

router = APIRouter(prefix="/api/users", tags=["Users"])


def _user_response(user: User) -> UserResponse:
    return UserResponse(
        id=str(user.id),
        name=user.name,
        email=user.email,
        phone=user.phone,
        profile_picture_url=user.profile_picture_url,
        role=user.role,
        is_verified=user.is_verified,
        created_at=user.created_at
    )


@router.get("/me", response_model=UserResponse)
async def get_profile(current_user: User = Depends(get_current_verified_user)):
    return _user_response(current_user)


@router.put("/me", response_model=UserResponse)
async def update_profile(
    body: UpdateProfileRequest,
    current_user: User = Depends(get_current_verified_user)
):
    if body.name:
        current_user.name = body.name
    current_user.updated_at = datetime.utcnow()
    await current_user.save()
    return _user_response(current_user)


@router.post("/upload-picture", response_model=UserResponse)
async def upload_picture(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_verified_user)
):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    file_bytes = await file.read()
    if len(file_bytes) > 5 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File too large. Max 5MB")
    url = await StorageService.upload(file_bytes, folder="profile_pictures")
    if not url:
        raise HTTPException(status_code=500, detail="Failed to upload image. Check Cloudinary config")

    current_user.profile_picture_url = url
    current_user.updated_at = datetime.utcnow()
    await current_user.save()
    return _user_response(current_user)


@router.put("/password")
async def change_password(
    body: ChangePasswordRequest,
    current_user: User = Depends(get_current_verified_user)
):
    if not verify_password(body.current_password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    if body.new_password != body.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    current_user.password_hash = hash_password(body.new_password)
    current_user.updated_at = datetime.utcnow()
    await current_user.save()
    return {"message": "Password changed successfully"}


@router.delete("/me")
async def delete_account(current_user: User = Depends(get_current_verified_user)):
    await current_user.delete()
    return {"message": "Account deleted successfully"}
