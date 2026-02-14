from pydantic import BaseModel

class StatusPayload(BaseModel):
    device_id: str
    auth_token: str
    firmware_version: str
