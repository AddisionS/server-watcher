from pydantic import BaseModel, Field


class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=32)
    password: str = Field(..., min_length=8)
    role: str = Field(..., description="admin_read | admin_write | dev")


class UserOut(BaseModel):
    username: str
    role: str
