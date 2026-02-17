from datetime import datetime, timezone
from app.db.influx import query_data


def get_all_alerts(limit: int = 100) -> list[dict]:
    limit = int(limit)
    limit = max(1, min(limit, 1000))

    sql = f"""
    SELECT
        time,
        device_id,
        device_name,
        temperature,
        humidity
    FROM alerts
    ORDER BY time DESC
    LIMIT {limit}
    """

    return query_data(sql)


def get_device_alerts_csv(
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
        device_id,
        device_name,
        temperature,
        humidity
    FROM alerts
    WHERE device_id = '{device_id}'
      AND time >= '{start.isoformat()}'
      AND time <= '{end.isoformat()}'
    ORDER BY time ASC
    """

    rows = query_data(sql)

    lines = ["time,device_id,device_name,temperature,humidity"]

    for row in rows:
        timestamp = row["time"]
        if hasattr(timestamp, "isoformat"):
            timestamp = timestamp.isoformat()

        lines.append(
            f"{timestamp},"
            f"{row['device_id']},"
            f"{row.get('device_name', '')},"
            f"{row['temperature']},"
            f"{row['humidity']}"
        )

    return "\n".join(lines)