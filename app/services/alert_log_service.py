from datetime import datetime, timezone
from app.db.influx import write_alerts_lp


def log_alert(
    *,
    device_id: str,
    location: str | None,
    temperature: float,
    humidity: float,
    timestamp: datetime | None = None,
) -> None:
    if timestamp is None:
        timestamp = datetime.now(timezone.utc)
    elif timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)

    ts_ns = int(timestamp.timestamp() * 1_000_000_000)

    tags = f"device_id={device_id}"
    if location:
        tags += f",location={location}"

    fields = f"temperature={temperature},humidity={humidity}"

    line = f"alert_events,{tags} {fields} {ts_ns}"

    write_alerts_lp(line)
