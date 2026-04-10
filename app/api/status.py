from fastapi import APIRouter, HTTPException, Depends
from app.models.status import StatusPayload
from app.services.device_auth_service import is_device_authorized
from app.services.device_state_service import process_device_status, get_device_status
from app.core.deps import require_role
from app.core.roles import Role


router = APIRouter(
    prefix="/status",
    tags=["status"],
)

@router.post("")
async def receive_status(payload: StatusPayload):
    if not is_device_authorized(
            device_id=payload.device_id,
            auth_token=payload.auth_token
    ):
        raise HTTPException(status_code=401, detail="Unauthorized device")

    process_device_status(
        device_id=payload.device_id,
        firmware_version=payload.firmware,
        uptime_sec=payload.uptime_sec,
        sensor=payload.components.sensor
    )

    return {"status": "ok"}

@router.get("/{device_id}")
async def send_status(
        device_id: str,
        user=Depends(require_role(Role.USER, Role.ADMIN, Role.DEVELOPER))
):
    device_data = get_device_status(device_id=device_id)

    if device_data is None:
        raise HTTPException(status_code=404, detail="Device not found")

    return device_data