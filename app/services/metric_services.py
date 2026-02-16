from app.db.influx import query_data
from datetime import datetime


def get_latest_metrics(device_id: str) -> dict | None:
    sql = f"""
    SELECT
        time,
        temperature,
        humidity
    FROM metrics
    WHERE device_id = '{device_id}'
    ORDER BY time DESC
    LIMIT 1
    """

    result = query_data(sql)

    if not result:
        return None

    row = result[0]

    return {
        "device_id": device_id,
        "timestamp": row.get("time"),
        "temperature": row.get("temperature"),
        "humidity": row.get("humidity"),
    }

def get_metrics_csv(
    *,
    device_id: str,
    start: datetime,
    end: datetime,
) -> str:
    sql = f"""
    SELECT
        time,
        temperature,
        humidity
    FROM sensor_readings
    WHERE device_id = '{device_id}'
      AND time >= '{start.isoformat()}'
      AND time <= '{end.isoformat()}'
    ORDER BY time ASC
    """

    rows = query_data(sql)

    lines = ["time,temperature,humidity"]

    for row in rows:
        lines.append(
            f"{row['time']},{row['temperature']},{row['humidity']}"
        )

    return "\n".join(lines)
