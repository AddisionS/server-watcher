from pydantic import BaseModel, Field


class IngestPayload(BaseModel):
    device_id: str = Field(..., description="Unique device identifier")
    auth_token: str = Field(..., description="Unique authorization token given to every device")

    temperature: float = Field(..., description="Temperature in Celsius")
    humidity: float = Field(..., description="Humidity percentage")
