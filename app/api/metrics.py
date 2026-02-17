from fastapi import APIRouter, Depends, HTTPException, Response
from datetime import datetime
from app.services.device_db_service import get_device_name
from app.services.metric_services import (
    get_latest_metrics,
    get_metrics_csv,
)
from app.core.deps import require_role
from app.core.roles import Role


router = APIRouter(
    prefix="/metrics",
    tags=["metrics"],
)


@router.get("/latest/{device_id}")
def get_latest_device_metrics(
    device_id: str,
    user=Depends(require_role(Role.USER, Role.ADMIN, Role.DEVELOPER)),
):
    data = get_latest_metrics(device_id)

    if not data:
        raise HTTPException(
            status_code=404,
            detail="No data found for this device",
        )

    return data


@router.get("/export/{device_id}")
def export_device_metrics_csv(
    device_id: str,
    start: datetime,
    end: datetime,
    user=Depends(require_role(Role.USER, Role.ADMIN, Role.DEVELOPER)),
):
    if start >= end:
        raise HTTPException(
            status_code=400,
            detail="Start time must be before end time",
        )

    csv_data = get_metrics_csv(
        device_id=device_id,
        start=start,
        end=end,
    )

    device_name = get_device_name(device_id=device_id)
    filename = f"{device_name}_{device_id}_{start.date()}_{end.date()}.csv"

    return Response(
        content=csv_data,
        media_type="text/csv",
        headers={
            "Content-Disposition": f"attachment; filename={filename}"
        },
    )
