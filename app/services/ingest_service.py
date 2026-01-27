from datetime import datetime, timezone
from app.db.influx import write_metrics_lp
from app.core.logger import logger


def write_sensor_data(
    *,
    device_id: str,
    location: str | None,
    temperature: float,
    humidity: float,
    timestamp: datetime | None,
) -> None:

    try:
        if timestamp is None:
            timestamp = datetime.now(timezone.utc)
        elif timestamp.tzinfo is None:
            timestamp = timestamp.replace(tzinfo=timezone.utc)

        tags = f"device_id={device_id}"
        if location:
            tags += f",location={location}"

        fields = f"temperature={temperature},humidity={humidity}"

        ts_ns = int(timestamp.timestamp() * 1_000_000_000)

        line = f"sensor_readings,{tags} {fields} {ts_ns}"

        write_metrics_lp(line)
    except Exception as e:
        logger.error(
            "Failed to write sensor data to InfluxDB",
            exc_info=True,
            extra={
                "device_id": device_id,
                "location": location,
            },
        )
