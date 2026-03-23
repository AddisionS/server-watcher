from datetime import datetime, timezone
from zoneinfo import ZoneInfo

from app.services.email_service import send_email
from app.services.whatsapp_service import send_whatsapp_alert
from app.core.logger import logger


def dispatch_alert(
    *,
    device_id: str,
    device_name: str | None,
    temperature: float,
    humidity: float,
) -> None:
    device_name = device_name or "Unknown location"

    ts = datetime.now(ZoneInfo("Asia/Kolkata"))

    temperature_str = f"{temperature:.1f} °C"
    humidity_str = f"{humidity:.1f} %"
    timestamp_str = ts.strftime("%d %b %Y, %H:%M:%S %Z")

    email_body = (
        "🚨 ServerWatcher Alert 🚨\n\n"
        f"Device ID: {device_id}\n"
        f"Device Name: {device_name}\n"
        f"Temperature: {temperature_str}\n"
        f"Humidity: {humidity_str}\n"
        f"Time: {timestamp_str}\n"
    )

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

    try:
        send_whatsapp_alert(
            device_id=device_id,
            location=device_name,
            temperature=temperature_str,
            humidity=humidity_str,
            timestamp=timestamp_str,
        )
    except Exception:
        logger.error(
            "Failed to send WhatsApp alert",
            exc_info=True,
        )
