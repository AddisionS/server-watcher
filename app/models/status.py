from pydantic import BaseModel

class Components(BaseModel):
    sensor: str

class StatusPayload(BaseModel):
    device_id: str
    auth_token: str
    firmware_version: str
    uptime_sec: float
    components: Components