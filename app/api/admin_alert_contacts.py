from fastapi import APIRouter, Depends, HTTPException
from app.core.model import EmailPayload, PhonePayload

from app.services.alert_contact_service import (
    load_alert_contacts,
    add_alert_email,
    remove_alert_email,
    add_alert_phone,
    remove_alert_phone,
)
from app.core.alert_cache import ALERT_EMAILS, ALERT_PHONES
from app.core.deps import require_role
from app.core.roles import Role

router = APIRouter(
    prefix="/admin/alerts",
    tags=["admin"],
)


@router.get("/emails")
def list_alert_emails(
    user=Depends(require_role(Role.USER, Role.DEVELOPER, Role.ADMIN)),
):
    return {"emails": sorted(ALERT_EMAILS)}


@router.post("/emails")
def add_email(
    payload: EmailPayload,
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER)),
):
    try:
        add_alert_email(payload.email)
    except Exception:
        raise HTTPException(status_code=400, detail="Failed to add alert email")

    return {"status": "added", "email": payload.email}


@router.delete("/emails")
def remove_email(
    payload: EmailPayload,
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER)),
):
    remove_alert_email(payload.email)
    return {"status": "removed", "email": payload.email}


@router.get("/phones")
def list_alert_phones(
    user=Depends(require_role(Role.USER, Role.ADMIN, Role.DEVELOPER)),
):
    return {"phones": sorted(ALERT_PHONES)}


@router.post("/phones")
def add_phone(
    payload: PhonePayload,
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER)),
):
    try:
        add_alert_phone(payload.phone)
    except Exception:
        raise HTTPException(status_code=400, detail="Failed to add alert phone number")

    return {"status": "added", "phone": payload.phone}


@router.delete("/phones")
def remove_phone(
    payload: PhonePayload,
    user=Depends(require_role(Role.ADMIN, Role.DEVELOPER)),
):
    remove_alert_phone(payload.phone)
    return {"status": "removed", "phone": payload.phone}