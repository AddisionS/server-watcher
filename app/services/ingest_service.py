from app.db.influx import write_metric
from app.services.device_db_service import get_device_name
from app.core.logger import logger


def write_sensor_data(
    *,
    device_id: str,
    temperature: float,
    humidity: float,
) -> None:

    device_name = get_device_name(device_id=device_id)
    if device_name is None:
        logger.warning(
            "Device not found in database",
            extra={"device_id": device_id}
        )
        device_name = "unknown"

    try:
        write_metric(
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
