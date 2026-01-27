from pydantic import BaseModel


class ThresholdUpdate(BaseModel):
    temp_min: float
    temp_max: float
    humidity_min: float
    humidity_max: float
