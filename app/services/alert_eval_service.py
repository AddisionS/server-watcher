import app.cache.threshold_cache as threshold_cache
from app.services.alert_dispatch_service import dispatch_alert
from app.services.device_db_service import get_device_name
from app.core.logger import logger
from app.db.influx import write_alert
import app.cache.device_status_cache as status_cache


def evaluate_and_log_alert(
    *,
    device_id: str,
    temperature: float,
    humidity: float,
) -> None:

    if status_cache.DEVICECACHE is None:
        logger.error("Status cache not initialized")
        return

    if threshold_cache.THRESHOLDS is None:
        logger.error("Threshold cache not initialized")
        return

    device = status_cache.DEVICECACHE._devices.get(device_id)
    if device is None:
        logger.warning("Device not found in cache", extra={"device_id": device_id})
        return

    device_name = get_device_name(device_id=device_id) or "unknown"

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
        try:
            write_alert(
                device_id=device_id,
                device_name=device_name,
                temperature=temperature,
                humidity=humidity,
            )
        except Exception:
            logger.error(
                "Failed to write alert to InfluxDB",
                exc_info=True,
                extra={"device_id": device_id, "device_name": device_name},
            )

    if breached and not device.alert_active:
        logger.info("Threshold exceeded — dispatching alert")

        dispatch_alert(
            device_id=device_id,
            device_name=device_name,
            temperature=temperature,
            humidity=humidity,
        )

        device.alert_active = True

    elif not breached and device.alert_active:
        device.alert_active = False
