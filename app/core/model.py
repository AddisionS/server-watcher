from pydantic import BaseModel, EmailStr

class EmailPayload(BaseModel):
    email: EmailStr

class PhonePayload(BaseModel):
    phone: str  # E.164 format e.g. +14155552671