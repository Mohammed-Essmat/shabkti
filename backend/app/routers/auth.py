from fastapi import APIRouter, HTTPException, status
from app.schemas.auth import (
    RegisterRequest, VerifyOTPRequest, SetPasswordRequest,
    LoginRequest, TokenResponse, RefreshTokenRequest,
    ForgotPasswordRequest, ResetPasswordRequest
)
from app.models.user import User
from app.models.otp import OTP
from app.services.otp_service import OTPService
from app.utils.security import hash_password, verify_password, create_access_token, create_refresh_token, decode_token

router = APIRouter(prefix="/api/auth", tags=["Auth"])


@router.post("/register", status_code=status.HTTP_200_OK)
async def register(body: RegisterRequest):
    if await User.find_one(User.email == body.email):
        raise HTTPException(status_code=400, detail="Email already registered")
    if await User.find_one(User.phone == body.phone):
        raise HTTPException(status_code=400, detail="Phone already registered")

    temp_data = {"name": body.name, "phone": body.phone}
    await OTPService.create_and_send(
        identifier=body.email,
        otp_type="both",
        purpose="register",
        temp_user_data=temp_data
    )
    return {"message": "OTP sent to email and phone"}


@router.post("/verify-otp", status_code=status.HTTP_200_OK)
async def verify_otp(body: VerifyOTPRequest):
    verified = await OTPService.verify(body.identifier, body.code)
    if not verified:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    return {"verified": True}


@router.post("/set-password", status_code=status.HTTP_201_CREATED)
async def set_password(body: SetPasswordRequest):
    if body.password != body.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    otp = await OTP.find_one(
        OTP.identifier == body.identifier,
        OTP.verified == True,
        OTP.purpose == "register"
    )
    if not otp:
        raise HTTPException(status_code=400, detail="OTP not verified. Please verify OTP first")

    temp = otp.temp_user_data or {}
    name = temp.get("name")
    phone = temp.get("phone")
    if not name or not phone:
        raise HTTPException(status_code=400, detail="Registration data missing. Please restart registration")

    if await User.find_one(User.email == body.identifier):
        raise HTTPException(status_code=400, detail="Account already exists")

    user = User(
        name=name,
        email=body.identifier,
        phone=phone,
        password_hash=hash_password(body.password),
        is_verified=True,
        role="user"
    )
    await user.insert()
    await otp.delete()

    return {"message": "Account created successfully"}


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    user = await User.find_one(User.email == body.email)
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    if not user.is_verified:
        raise HTTPException(status_code=403, detail="Account not verified")

    user_id = str(user.id)
    access_token = create_access_token({"sub": user_id})
    refresh_token = create_refresh_token({"sub": user_id})
    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(body: RefreshTokenRequest):
    payload = decode_token(body.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user_id = payload.get("sub")
    user = await User.get(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    access_token = create_access_token({"sub": user_id})
    new_refresh_token = create_refresh_token({"sub": user_id})
    return TokenResponse(access_token=access_token, refresh_token=new_refresh_token)


@router.post("/forgot-password", status_code=status.HTTP_200_OK)
async def forgot_password(body: ForgotPasswordRequest):
    user = await User.find_one(User.email == body.email)
    if user:
        await OTPService.create_and_send(
            identifier=body.email,
            otp_type="email",
            purpose="reset_password"
        )
    return {"message": "If this email is registered, an OTP has been sent"}


@router.post("/reset-password", status_code=status.HTTP_200_OK)
async def reset_password(body: ResetPasswordRequest):
    if body.password != body.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    otp = await OTP.find_one(
        OTP.identifier == body.identifier,
        OTP.verified == True,
        OTP.purpose == "reset_password"
    )
    if not otp:
        raise HTTPException(status_code=400, detail="OTP not verified")

    user = await User.find_one(User.email == body.identifier)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password_hash = hash_password(body.password)
    await user.save()
    await otp.delete()

    return {"message": "Password reset successfully"}
