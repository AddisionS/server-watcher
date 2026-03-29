from app.db.influx import query_data
from datetime import datetime, timezone , timedelta
import re

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

def     get_last_24h_metrics(device_id: str) -> list[dict]:
    """
    Retrieve all metrics for a device over the past 24 hours.
    
    Args:
        device_id: The device identifier to query.
    
    Returns:
        A list of metric dicts with keys: device_id, device_name, timestamp, temperature, humidity.
    """
    if not re.match(r'^[a-zA-Z0-9\-]+$', device_id):
        raise ValueError("Invalid device_id")

    end = datetime.now(timezone.utc)
    start = end - timedelta(hours=24)

    sql = f"""
    SELECT
        device_name,
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

    results = []
    for row in rows:
        timestamp = row.get("time")
        if timestamp and hasattr(timestamp, "isoformat"):
            timestamp = timestamp.isoformat()

        results.append({
            "device_id": device_id,
            "device_name": row.get("device_name"),
            "timestamp": timestamp,
            "temperature": row.get("temperature"),
            "humidity": row.get("humidity"),
        })

    return results

def get_metrics_csv(
    *,
    device_id: str,
    start: datetime,
    end: datetime,
) -> str:

    if not re.match(r'^[a-zA-Z0-9\-]+$', device_id):
        raise ValueError("Invalid device_id")
    
    if start.tzinfo is None:
        start = start.replace(tzinfo=timezone.utc)
    else:
        start = start.astimezone(timezone.utc)

    if end.tzinfo is None:
        end = end.replace(tzinfo=timezone.utc)
    else:
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
