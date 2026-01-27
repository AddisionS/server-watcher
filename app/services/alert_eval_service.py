from datetime import datetime

from app.core.threshold_cache import THRESHOLDS
from app.services.alert_log_service import log_alert
from app.services.alert_dispatch_service import dispatch_alert


def evaluate_and_log_alert(
    *,
    device_id: str,
    location: str | None,
    temperature: float,
    humidity: float,
    timestamp: datetime | None
) -> None:
    if THRESHOLDS is None:
        return

    breached = False

    if (
        temperature < THRESHOLDS["temp_min"]
        or temperature > THRESHOLDS["temp_max"]
    ):
        breached = True

    if (
        humidity < THRESHOLDS["humidity_min"]
        or humidity > THRESHOLDS["humidity_max"]
    ):
        breached = True

    if breached:
        log_alert(
            device_id=device_id,
            location=location,
            temperature=temperature,
            humidity=humidity,
            timestamp=timestamp
        )

        dispatch_alert(
            device_id=device_id,
            location=location,
            temperature=temperature,
            humidity=humidity,
            timestamp=timestamp
        )
