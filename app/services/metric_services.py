from app.db.influx import query_metrics
from datetime import datetime


def get_latest_metrics(device_id: str) -> dict | None:
    sql = f"""
    SELECT
        time,
        temperature,
        humidity
    FROM sensor_readings
    WHERE device_id = '{device_id}'
    ORDER BY time DESC
    LIMIT 1
    """

    rows = query_metrics(sql)

    if not rows:
        return None

    row = rows[0]

    return {
        "device_id": device_id,
        "timestamp": row["time"],
        "temperature": row["temperature"],
        "humidity": row["humidity"],
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

    rows = query_metrics(sql)

    lines = ["time,temperature,humidity"]

    for row in rows:
        lines.append(
            f"{row['time']},{row['temperature']},{row['humidity']}"
        )

    return "\n".join(lines)
