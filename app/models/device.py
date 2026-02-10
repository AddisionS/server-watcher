from pydantic import BaseModel

class DeviceCreate(BaseModel):
    device_name: str
