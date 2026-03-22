from fastapi import Depends, HTTPException, status
from app.core.security import decode_token
from enum import Enum


def require_role(*allowed_roles):
    def _checker(user=Depends(decode_token)):
        normalized_roles = [
            (role.value if isinstance(role, Enum) else role).lower()
            for role in allowed_roles
        ]

        if user["role"].lower() not in normalized_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )

        return user

    return _checker
