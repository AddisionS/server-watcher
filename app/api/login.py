from fastapi import APIRouter, HTTPException, status

from app.models.auth import LoginRequest, TokenResponse
from app.services.user_service import get_user
from app.core.security import verify_password, create_access_token

router = APIRouter(tags=["auth"])


@router.post("/login", response_model=TokenResponse)
def login(data: LoginRequest):
    user = get_user(data.username)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    if not verify_password(data.password, user["password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    token = create_access_token(
        subject=user["username"],
        role=user["role"],
    )

    return {
        "access_token": token,
        "token_type": "bearer",
        "role": user["role"],
    }
