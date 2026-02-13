from fastapi import APIRouter, Depends, HTTPException

from app.models.thresholds import ThresholdUpdate
from app.services.threshold_service import (
    get_thresholds,
    update_thresholds,
)
from app.core.deps import require_role
from app.core.roles import ADMIN, DEVELOPER, USER


router = APIRouter(
    prefix="/admin/thresholds",
    tags=["admin"],
)


@router.get("/")
def read_thresholds(
    user=Depends(require_role(ADMIN, USER, DEVELOPER)),
):
    return get_thresholds()


@router.put("/")
def change_thresholds(
    data: ThresholdUpdate,
    user=Depends(require_role(ADMIN, DEVELOPER)),
):
    try:
        update_thresholds(
            temp_min=data.temp_min,
            temp_max=data.temp_max,
            humidity_min=data.humidity_min,
            humidity_max=data.humidity_max,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return {"status": "updated"}

