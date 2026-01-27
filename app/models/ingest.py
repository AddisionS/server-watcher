from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class IngestPayload(BaseModel):
    # identity
    device_id: str = Field(..., description="Unique device identifier")
    auth_token: str = Field(..., description="Unique authorization token given to every device")

    # sensor readings
    temperature: float = Field(..., description="Temperature in Celsius")
    humidity: float = Field(..., description="Humidity percentage")

    # metadata 
    location: Optional[str] = Field(
        None, description="Physical location of the device"
    )

    # time handling
    timestamp: Optional[datetime] = Field(
        None,
        description="Device timestamp (server time used if missing)",
    )
