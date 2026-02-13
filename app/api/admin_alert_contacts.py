from fastapi import APIRouter, Depends, HTTPException, Query

from app.services.alert_contact_service import (
    load_alert_contacts,
    add_alert_email,
    remove_alert_email,
    add_alert_phone,
    remove_alert_phone,
)
from app.core.alert_cache import ALERT_EMAILS, ALERT_PHONES
from app.core.deps import require_role
from app.core.roles import USER, ADMIN, DEVELOPER

router = APIRouter(
    prefix="/admin/alerts",
    tags=["admin"],
)


@router.get("/emails")
def list_alert_emails(
    user=Depends(require_role(USER, ADMIN, DEVELOPER)),
):
    return {
        "emails": sorted(ALERT_EMAILS)
    }


@router.post("/emails")
def add_email(
    email: str = Query(..., description="Alert email address"),
    user=Depends(require_role(ADMIN, DEVELOPER)),
):
    try:
        add_alert_email(email)
    except Exception:
        raise HTTPException(
            status_code=400,
            detail="Failed to add alert email",
        )

    return {
        "status": "added",
        "email": email,
    }


@router.delete("/emails")
def remove_email(
    email: str = Query(..., description="Alert email address"),
    user=Depends(require_role(ADMIN, DEVELOPER)),
):
    remove_alert_email(email)

    return {
        "status": "removed",
        "email": email,
    }


@router.get("/phones")
def list_alert_phones(
    user=Depends(require_role(USER, ADMIN, DEVELOPER)),
):
    return {
        "phones": sorted(ALERT_PHONES)
    }

@router.post("/phones")
def add_phone(
    phone: str = Query(..., description="Alert phone number in E.164 format"),
    user=Depends(require_role(ADMIN, DEVELOPER)),
):
    try:
        add_alert_phone(phone)
    except Exception:
        raise HTTPException(
            status_code=400,
            detail="Failed to add alert phone number",
        )

    return {
        "status": "added",
        "phone": phone,
    }

@router.delete("/phones")
def remove_phone(
    phone: str = Query(..., description="Alert phone number in E.164 format"),
    user=Depends(require_role(ADMIN, DEVELOPER)),
):
    remove_alert_phone(phone)

    return {
        "status": "removed",
        "phone": phone,
    }
