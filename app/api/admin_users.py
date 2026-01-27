from fastapi import APIRouter, Depends, HTTPException

from app.models.user import UserCreate, UserOut
from app.services.user_service import add_user, delete_user, list_users
from app.core.deps import require_role
from app.core.roles import ADMIN_WRITE, DEVELOPER

router = APIRouter(
    prefix="/admin/users",
    tags=["admin"],
)

@router.post("/", response_model=UserOut)
def create_user(
    data: UserCreate,
    user=Depends(require_role(ADMIN_WRITE, DEVELOPER)),
):
    try:
        add_user(
            username=data.username,
            password=data.password,
            role=data.role,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return {
        "username": data.username,
        "role": data.role,
    }


@router.delete("/{username}")
def remove_user(
    username: str,
    user=Depends(require_role(ADMIN_WRITE, DEVELOPER)),
):
    if username == user["sub"]:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete yourself",
        )

    delete_user(username=username)
    return {"status": "deleted"}


@router.get("/", response_model=list[UserOut])
def get_users(
    user=Depends(require_role(ADMIN_WRITE, DEVELOPER)),
):
    return list_users()
