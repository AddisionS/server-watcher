from datetime import datetime
from app.db.influx import query_alerts

def get_all_alerts(limit: int = 100) -> list[dict]:
    sql = f"""
    SELECT
        time,
        device_id,
        location,
        temperature,
        humidity
    FROM alert_events
    ORDER BY time DESC
    LIMIT {limit}
    """
    return query_alerts(sql)


def get_device_alerts_csv(
    *,
    device_id: str,
    start: datetime | None = None,
    end: datetime | None = None,
) -> str:
    where_clauses = [f"device_id = '{device_id}'"]

    if start:
        where_clauses.append(f"time >= '{start.isoformat()}'")
    if end:
        where_clauses.append(f"time <= '{end.isoformat()}'")

    where_sql = " AND ".join(where_clauses)

    sql = f"""
    SELECT
        time,
        device_id,
        location,
        temperature,
        humidity
    FROM alert_events
    WHERE {where_sql}
    ORDER BY time ASC
    """

    rows = query_alerts(sql)

    # CSV
    lines = ["time,device_id,location,temperature,humidity"]

    for row in rows:
        lines.append(
            f"{row['time']},"
            f"{row['device_id']},"
            f"{row.get('location','')},"
            f"{row['temperature']},"
            f"{row['humidity']}"
        )

    return "\n".join(lines)
