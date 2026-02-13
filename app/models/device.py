from pydantic import BaseModel

class DeviceCreate(BaseModel):
    device_name: str

class DeviceUpdate(BaseModel):
    device_id: str
    device_name: str