import requests
from influxdb_client_3 import InfluxDBClient3
from app.core.config import INFLUX_URL, INFLUX_TOKEN, INFLUX_DB
from app.core.logger import logger
from typing import Dict, Any

client = InfluxDBClient3(
    host=INFLUX_URL,
    database=INFLUX_DB,
    token=INFLUX_TOKEN
)

def database_exists() -> bool:
    url = f"{INFLUX_URL}/api/v3/configure/database"
    headers = {
        "Authorization": f"Bearer {INFLUX_TOKEN}",
    }
    try:
        response = requests.get(url, headers=headers, params={"format": "json"})
        if response.status_code == 200:
            databases = response.json()
            return any(db.get("iox::database") == INFLUX_DB for db in databases)
        return False
    except Exception as e:
        logger.exception(f"Exception while checking existing database: {e}")
        return False


def create_database():
    if database_exists():
        return True

    url = f"{INFLUX_URL}/api/v3/configure/database"
    headers = {
        "Authorization": f"Bearer {INFLUX_TOKEN}",
        "Content-Type": "application/json"
    }
    payload = {"db": INFLUX_DB}

    try:
        response = requests.post(url, headers=headers, json=payload)
        return response.status_code == 200
    except Exception as e:
        logger.exception(f"Exception while creating database: {e}")
        return False

def write_data(*, measurement: str, tags: Dict[str, str], fields: Dict[str, Any]) -> bool:
    point = {
        "measurement": measurement,
        "tags": tags,
        "fields": fields
    }

    try:
        client.write(record=point)
        return True
    except Exception as e:
        logger.exception(f"Failed to write to influxdb: {e}")
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

def query_data(sql: str):
    table = client.query(sql)
    df = table.to_pandas()
    return df.to_dict(orient="records")
