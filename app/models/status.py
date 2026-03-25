from pydantic import BaseModel
from typing import Literal

class Components(BaseModel):
    sensor: Literal["ok", "dead"]

class StatusPayload(BaseModel):
    device_id: str
    auth_token: str
    firmware: str
    uptime_sec: float
    components: Components