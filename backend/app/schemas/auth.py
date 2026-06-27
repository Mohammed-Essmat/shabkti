from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class RegisterRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(..., pattern=r"^\+?[1-9]\d{1,14}$")

class SendOTPRequest(BaseModel):
    identifier: str
    type: str = Field(..., pattern="^(email|sms|both)$")

class VerifyOTPRequest(BaseModel):
    identifier: str
    code: str = Field(..., min_length=6, max_length=6)

class SetPasswordRequest(BaseModel):
    identifier: str
    password: str = Field(..., min_length=6)
    confirm_password: str = Field(..., min_length=6)

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    identifier: str
    password: str = Field(..., min_length=6)
    confirm_password: str = Field(..., min_length=6)
