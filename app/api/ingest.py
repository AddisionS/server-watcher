from fastapi import APIRouter, HTTPException
from app.models.ingest import IngestPayload
from app.services.device_auth_service import is_device_authorized
from app.services.ingest_service import write_sensor_data
from app.services.alert_eval_service import evaluate_and_log_alert

router = APIRouter(
    prefix="/ingest",
    tags=["ingest"],
)

@router.post("")
async def ingest_data(payload: IngestPayload):
    if not is_device_authorized(
        device_id=payload.device_id,
        auth_token=payload.auth_token,
    ):
        raise HTTPException(status_code=401, detail="Unauthorized device")

    write_sensor_data(
        device_id=payload.device_id,
        temperature=payload.temperature,
        humidity=payload.humidity,
    )

    evaluate_and_log_alert(
        device_id=payload.device_id,
        temperature=payload.temperature,
        humidity=payload.humidity,
    )

    return {"status": "ok"}
