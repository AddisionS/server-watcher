from fastapi import APIRouter, Depends, HTTPException, Response
from datetime import datetime, timezone
from dateutil import parser as dateutil_parser
from app.services.device_db_service import get_device_name
from app.services.metric_services import (
    get_latest_metrics,
    get_metrics_csv,
    get_last_24h_metrics,
)
from app.core.deps import require_role
from app.core.roles import Role
import re


router = APIRouter(
    prefix="/metrics",
    tags=["metrics"],
)


def normalize_to_utc(dt: datetime) -> datetime:
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)


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


@router.get("/24h/{device_id}")
def get_last_24h_device_metrics(
    device_id: str,
    user=Depends(require_role(Role.USER, Role.ADMIN, Role.DEVELOPER)),
):
    data = get_last_24h_metrics(device_id=device_id)

    if not data:
        raise HTTPException(
            status_code=404,
            detail="No data found for this device in the last 24 hours",
        )

    return data


@router.get("/export/{device_id}")
def export_device_metrics_csv(
    device_id: str,
    start: str,
    end: str,
    user=Depends(require_role(Role.USER, Role.ADMIN, Role.DEVELOPER)),
):
    try:
        start_dt = normalize_to_utc(dateutil_parser.parse(start))
        end_dt = normalize_to_utc(dateutil_parser.parse(end))
    except (ValueError, OverflowError):
        raise HTTPException(
            status_code=400,
            detail="Invalid datetime format for start or end",
        )

    if start_dt >= end_dt:
        raise HTTPException(
            status_code=400,
            detail="Start time must be before end time",
        )

    csv_data = get_metrics_csv(
        device_id=device_id,
        start=start_dt,
        end=end_dt,
    )

    device_name = get_device_name(device_id=device_id)
    safe_device_name = re.sub(r'[^\w\-]', '_', device_name or "device")
    safe_device_id = re.sub(r'[^\w\-]', '_', device_id)
    filename = f"{safe_device_name}_{safe_device_id}_{start_dt.date()}_{end_dt.date()}.csv"

    return Response(
        content=csv_data,
        media_type="text/csv",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"'
        },
    )