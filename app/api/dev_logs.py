from fastapi import APIRouter, Depends, Query
from fastapi.responses import PlainTextResponse

from app.services.log_read_service import read_logs
from app.core.deps import require_role
from app.core.roles import DEVELOPER

router = APIRouter(
    prefix="/dev/logs",
    tags=["developer"],
)

@router.get("/")
def read_server_logs(
    lines: int = Query(200, ge=10, le=5000),
    user=Depends(require_role(DEVELOPER)),
):
    logs = read_logs(lines=lines)

    return PlainTextResponse(
        content=logs,
        media_type="text/plain",
    )
