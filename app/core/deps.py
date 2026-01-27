from fastapi import Depends, HTTPException, status
from app.core.security import decode_token


def require_role(*allowed_roles: str):
    def _checker(user=Depends(decode_token)):
        if user["role"] not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return user
    return _checker
