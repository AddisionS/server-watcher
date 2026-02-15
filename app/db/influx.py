import requests
from app.core.config import INFLUX_URL, INFLUX_TOKEN, INFLUX_DB
from typing import Dict, Any

def create_database():
    url = f"{INFLUX_URL}/api/v3/configure/database"
    headers = {
        "Authorization": f"Bearer {INFLUX_TOKEN}",
        "Content-Type": "application/json"
    }
    payload = {
        "db": INFLUX_DB
    }
    try:
        response = requests.post(url, headers=headers, json=payload)

        if response.status_code == 200:
            return True
        elif response.status_code == 409:
            return True
        else:
            return False

    except requests.exceptions.RequestException as e:
        return False

def write_data(*, measurement: str, tags: Dict[str, str], fields: Dict[str, Any]) -> bool:
    tag_str = ','.join([f"{k}={v}" for k, v in tags.items()]) if tags else ""
    field_str = ','.join([f"{k}={v}" for k, v in fields.items()])

    if tag_str:
        line_protocol = f"{measurement},{tag_str} {field_str}"
    else:
        line_protocol = f"{measurement} {field_str}"

    headers = {
        "Authorization": f"Bearer {INFLUX_TOKEN}",
        "Content-Type": "text/plain"
    }

    try:
        response = requests.post(
            f"{INFLUX_URL}/api/v3/write_lp?db={INFLUX_DB}",
            headers=headers,
            data=line_protocol,
            timeout=2
        )
        return response.status_code == 204
    except requests.exceptions.RequestException:
        return False

def write_metric(*, device_id: str, device_name: str, temperature: float, humidity: float):
    return write_data(measurement="metrics",
                      tags={"device_id": device_id, "device_name": device_name},
                      fields={"temperature": temperature, "humidity": humidity}
                      )

def write_alert(*, device_id: str, device_name: str, temperature: float, humidity: float):
    return write_data(measurement="alerts",
                      tags={"device_id": device_id, "device_name": device_name},
                      fields={"temperature": temperature, "humidity": humidity}
                      )


# METRICS_DB = "serverwatcher_metrics"
# ALERTS_DB = "serverwatcher_alerts"
#
# QUERY_ENDPOINT = f"{INFLUX_URL}/api/v3/query"
# WRITE_ENDPOINT = f"{INFLUX_URL}/api/v3/write_lp"
#
# def query_influx(sql: str, *, db: str) -> list[dict]:
#     response = requests.post(
#         QUERY_ENDPOINT,
#         params={"db": db},
#         json={"q": sql},
#         timeout=5,
#     )
#     response.raise_for_status()
#     return response.json().get("data", [])
#
#
#
# def query_metrics(sql: str) -> list[dict]:
#     return query_influx(sql, db=METRICS_DB)
#
#
# def write_metrics_lp(line: str) -> None:
#     response = requests.post(
#         WRITE_ENDPOINT,
#         params={"db": METRICS_DB},
#         data=line,
#         timeout=2,
#     )
#     response.raise_for_status()
#
#
# def query_alerts(sql: str) -> list[dict]:
#     return query_influx(sql, db=ALERTS_DB)
#
#
# def write_alerts_lp(line: str) -> None:
#     response = requests.post(
#         WRITE_ENDPOINT,
#         params={"db": ALERTS_DB},
#         data=line,
#         timeout=2,
#     )
#     response.raise_for_status()