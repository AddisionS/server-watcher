from app.db.influx import query_data
from datetime import datetime, timezone


def get_latest_metrics(device_id: str) -> dict | None:
    safe_device_id = device_id.replace("'", "''")

    sql = f"""
    SELECT
        device_name,
        time,
        temperature,
        humidity
    FROM metrics
    WHERE device_id = '{safe_device_id}'
    ORDER BY time DESC
    LIMIT 1
    """

    result = query_data(sql)

    if not result:
        return None

    row = result[0]

    timestamp = row.get("time")
    if timestamp:
        timestamp = timestamp.isoformat()

    return {
        "device_id": device_id,
        "device_name": row.get("device_name"),
        "timestamp": timestamp,
        "temperature": row.get("temperature"),
        "humidity": row.get("humidity"),
    }

def get_metrics_csv(
    *,
    device_id: str,
    start: datetime,
    end: datetime,
) -> str:

    if not device_id.isalnum():
        raise ValueError("Invalid device_id")

    start = start.astimezone(timezone.utc)
    end = end.astimezone(timezone.utc)

    sql = f"""
    SELECT
        time,
        temperature,
        humidity
    FROM metrics
    WHERE device_id = '{device_id}'
      AND time >= '{start.isoformat()}'
      AND time <= '{end.isoformat()}'
    ORDER BY time ASC
    """

    rows = query_data(sql)

    lines = ["time,temperature,humidity"]

    for row in rows:
        timestamp = row["time"]
        if hasattr(timestamp, "isoformat"):
            timestamp = timestamp.isoformat()

        lines.append(
            f"{timestamp},{row['temperature']},{row['humidity']}"
        )

    return "\n".join(lines)

