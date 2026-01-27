from datetime import datetime
from fastapi import APIRouter, Depends, Query
from fastapi.responses import Response

from app.services.alert_read_service import (
    get_all_alerts,
    get_device_alerts_csv,
)
from app.core.deps import require_role
from app.core.roles import ADMIN_READ, ADMIN_WRITE, DEVELOPER

router = APIRouter(
    prefix="/alerts",
    tags=["alerts"],
)

@router.get("/")
def read_all_alerts(
    limit: int = Query(100, ge=1, le=1000),
    user=Depends(require_role(ADMIN_READ, ADMIN_WRITE, DEVELOPER)),
):
    return get_all_alerts(limit=limit)


@router.get("/device/{device_id}/csv")
def download_device_alerts_csv(
    device_id: str,
    start: datetime | None = None,
    end: datetime | None = None,
    user=Depends(require_role(ADMIN_READ, ADMIN_WRITE, DEVELOPER)),
):
    csv_data = get_device_alerts_csv(
        device_id=device_id,
        start=start,
        end=end,
    )

    filename = f"alerts_{device_id}.csv"

    return Response(
        content=csv_data,
        media_type="text/csv",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"'
        },
    )
