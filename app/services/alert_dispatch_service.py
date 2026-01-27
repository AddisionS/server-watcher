from datetime import datetime, timezone

from app.services.email_service import send_email
from app.core.logger import logger


def dispatch_alert(
    *,
    device_id: str,
    location: str | None,
    temperature: float,
    humidity: float,
    timestamp:datetime | None,
) -> None:
    loc = location or "unknown location"
    if timestamp is None:
        timestamp = datetime.now(timezone.utc)
    elif timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)

    message = (
        "🚨 ServerWatcher Alert 🚨\n\n"
        f"Device ID: {device_id}\n"
        f"Location: {loc}\n"
        f"Temperature: {temperature}\n"
        f"Humidity: {humidity}\n"
        f"Time: {timestamp}\n"
    )

    try:
        send_email(
            subject="ServerWatcher Alert",
            body=message,
        )


    except Exception:
        logger.error(
            "Failed to dispatch alert notification",
            exc_info=True,
        )
