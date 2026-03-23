import app.core.threshold_cache as threshold_cache
from app.services.alert_dispatch_service import dispatch_alert
from app.services.device_db_service import get_device_name
from app.core.logger import logger
from app.db.influx import write_alert


def evaluate_and_log_alert(
    *,
    device_id: str,
    temperature: float,
    humidity: float,
) -> None:
    if threshold_cache.THRESHOLDS is None:
        return

    breached = False

    if (
        temperature < threshold_cache.THRESHOLDS["temp_min"]
        or temperature > threshold_cache.THRESHOLDS["temp_max"]
    ):
        breached = True

    if (
        humidity < threshold_cache.THRESHOLDS["humidity_min"]
        or humidity > threshold_cache.THRESHOLDS["humidity_max"]
    ):
        breached = True

    if breached:
        device_name = get_device_name(device_id=device_id)
        if device_name is None:
            logger.warning(
                "Device not found in database",
                extra={"device_id": device_id}
            )
            device_name = "unknown"

        try:
            write_alert(
                device_id=device_id,
                device_name=device_name,
                temperature=temperature,
                humidity=humidity
            )
        except Exception as e:
            logger.error(
                "Failed to write sensor data to InfluxDB",
                exc_info=True,
                extra={
                    "device_id": device_id,
                    "device_name": device_name,
                },
            )

        dispatch_alert(
            device_id=device_id,
            device_name=device_name,
            temperature=temperature,
            humidity=humidity,
        )