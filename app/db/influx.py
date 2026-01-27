# import requests
# from app.core.config import INFLUX_URL, INFLUX_DB
#
# QUERY_ENDPOINT = f"{INFLUX_URL}/api/v3/query"
#
#
# def query_influx(sql: str) -> list[dict]:
#     response = requests.post(
#         QUERY_ENDPOINT,
#         params={"db": INFLUX_DB},
#         json={"q": sql},
#         timeout=5,
#     )
#     response.raise_for_status()
#
#     data = response.json()
#
#     return data.get("data", [])


import requests
from app.core.config import INFLUX_URL

METRICS_DB = "serverwatcher_metrics"
ALERTS_DB = "serverwatcher_alerts"

QUERY_ENDPOINT = f"{INFLUX_URL}/api/v3/query"
WRITE_ENDPOINT = f"{INFLUX_URL}/api/v3/write_lp"



def query_influx(sql: str, *, db: str) -> list[dict]:
    response = requests.post(
        QUERY_ENDPOINT,
        params={"db": db},
        json={"q": sql},
        timeout=5,
    )
    response.raise_for_status()
    return response.json().get("data", [])



def query_metrics(sql: str) -> list[dict]:
    return query_influx(sql, db=METRICS_DB)


def write_metrics_lp(line: str) -> None:
    response = requests.post(
        WRITE_ENDPOINT,
        params={"db": METRICS_DB},
        data=line,
        timeout=2,
    )
    response.raise_for_status()


def query_alerts(sql: str) -> list[dict]:
    return query_influx(sql, db=ALERTS_DB)


def write_alerts_lp(line: str) -> None:
    response = requests.post(
        WRITE_ENDPOINT,
        params={"db": ALERTS_DB},
        data=line,
        timeout=2,
    )
    response.raise_for_status()
