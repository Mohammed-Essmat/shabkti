from fastapi import Depends, HTTPException, status, Cookie, Response
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.utils.security import decode_token
from app.models.user import User
from app.config import settings
import hashlib

security = HTTPBearer()

ADMIN_SESSION_TOKEN = hashlib.sha256(f"{settings.ADMIN_USERNAME}:{settings.ADMIN_PASSWORD}".encode()).hexdigest()


def verify_admin(admin_session: str = Cookie(None)):
    if admin_session != ADMIN_SESSION_TOKEN:
        raise HTTPException(status_code=status.HTTP_303_SEE_OTHER, headers={"Location": "/admin/login"})

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> User:
    token = credentials.credentials
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    user_id = payload.get("sub")
    user = await User.get(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

async def get_current_verified_user(current_user: User = Depends(get_current_user)) -> User:
    if not current_user.is_verified:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="User not verified")
    return current_user
