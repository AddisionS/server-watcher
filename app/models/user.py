from pydantic import BaseModel, Field
from app.core.roles import Role

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=32)
    password: str = Field(..., min_length=8)
    role: Role = Field(..., description="USER | ADMIN | DEVELOPER")


class UserOut(BaseModel):
    username: str
    role: str
