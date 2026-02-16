from fastapi import APIRouter, HTTPException
from app.models.status import StatusPayload
from app.services.device_auth_service import is_device_authorized


router = APIRouter(
    prefix="/status",
    tags=["status"],
)

@router.post("/")
async def recieve_status(payload: StatusPayload):
    if not is_device_authorized(
            device_id=payload.device_id,
            auth_token=payload.auth_token
    ):
        raise HTTPException(status_code=401, detail="Unauthorized device")