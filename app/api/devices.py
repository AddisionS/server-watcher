from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import Response

from app.services.device_db_service import count_devices, list_devices, delete_device, add_device, update_device
from app.core.deps import require_role
from app.core.roles import Role
from app.models.device import DeviceCreate, DeviceUpdate
from app.services.device_id_service import generate_device_id
from app.services.device_auth_token_service import generate_auth_token
from app.services.device_state_service import add_to_device_cache, remove_from_device_cache
from app.services.firmware_generation_service import generate_firmware

router = APIRouter(
    prefix="/admin/devices",
    tags=["admin"],
)

@router.get("/")
def get_devices(
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER, Role.USER)),
):
    return {
        "devices": list_devices()
    }

@router.get("/count")
def get_device_count(
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER, Role.USER)),
):
    return {
        "count": count_devices()
    }

@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_device(
    device_id: str,
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER)),
):
    deleted = delete_device(device_id=device_id)

    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found",
        )

    remove_from_device_cache(device_id=device_id)

@router.put("/", status_code=status.HTTP_204_NO_CONTENT)
def rename_device(
        data: DeviceUpdate,
        user=Depends(require_role(Role.ADMIN, Role.DEVELOPER))
):

    updated = update_device(device_id=data.device_id, device_name= data.device_name)

    if not updated:
        raise  HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found",
        )


@router.post("/")
def add_device_endpoint(
    data: DeviceCreate,
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER)),
):
    device_id = generate_device_id()
    auth_token = generate_auth_token()

    try:
        firmware = generate_firmware(
            device_id=device_id,
            auth_token=auth_token
        )
    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Failed to generate firmware",
        )

    try:
        add_device(
            device_id=device_id,
            device_name=data.device_name,
            auth_token=auth_token
        )
        add_to_device_cache(device_id=device_id)
    except ValueError as e:
        raise HTTPException(
            status_code=409,
            detail=str(e),
        )

    return Response(
        content=firmware,
        media_type="text/plain",
        headers={
            "Content-Disposition": f'attachment; filename="{data.device_name}_{device_id}.ino"'
        },
    )
