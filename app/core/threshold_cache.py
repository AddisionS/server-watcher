from typing import TypedDict


class Thresholds(TypedDict):
    temp_min: float
    temp_max: float
    humidity_min: float
    humidity_max: float


THRESHOLDS: Thresholds | None = None
