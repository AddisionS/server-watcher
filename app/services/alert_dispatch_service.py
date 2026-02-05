from datetime import datetime, timezone

from app.services.email_service import send_email
from app.services.whatsapp_service import send_whatsapp_alert
from app.core.logger import logger


def dispatch_alert(
    *,
    device_id: str,
    location: str | None,
    temperature: float,
    humidity: float,
    timestamp: datetime | None,
) -> None:
    loc = location or "Unknown location"

    if timestamp is None:
        ts = datetime.now(timezone.utc)
    elif timestamp.tzinfo is None:
        ts = timestamp.replace(tzinfo=timezone.utc)
    else:
        ts = timestamp

    # ---------- Normalized values ----------
    temperature_str = f"{temperature:.1f} °C"
    humidity_str = f"{humidity:.1f} %"
    timestamp_str = ts.strftime("%d %b %Y, %H:%M:%S %Z")

    # ---------- Email message (free text) ----------
    email_body = (
        "🚨 ServerWatcher Alert 🚨\n\n"
        f"Device ID: {device_id}\n"
        f"Location: {loc}\n"
        f"Temperature: {temperature_str}\n"
        f"Humidity: {humidity_str}\n"
        f"Time: {timestamp_str}\n"
    )

    # ---------- Dispatch Email ----------
    try:
        send_email(
            subject="ServerWatcher Alert",
            body=email_body,
        )
    except Exception:
        logger.error(
            "Failed to send alert email",
            exc_info=True,
        )

    # ---------- Dispatch WhatsApp ----------
    try:
        send_whatsapp_alert(
            device_id=device_id,
            location=loc,
            temperature=temperature_str,
            humidity=humidity_str,
            timestamp=timestamp_str,
        )
    except Exception:
        logger.error(
            "Failed to send WhatsApp alert",
            exc_info=True,
        )
