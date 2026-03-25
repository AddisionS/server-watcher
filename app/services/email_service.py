import smtplib
from email.message import EmailMessage

from app.core.config import (
    SMTP_HOST,
    SMTP_PORT,
    SMTP_USERNAME,
    SMTP_PASSWORD,
    SMTP_FROM,
)
from app.cache.alert_cache import ALERT_EMAILS
from app.core.logger import logger

def send_email(subject: str, body: str) -> None:
    if not ALERT_EMAILS:
        logger.warning("send_email called but ALERT_EMAILS is empty — skipping")
        return

    msg = EmailMessage()
    msg["From"] = SMTP_FROM
    msg["To"] = ", ".join(ALERT_EMAILS)
    msg["Subject"] = subject
    msg.set_content(body)

    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10) as server:
            server.starttls()
            server.login(SMTP_USERNAME, SMTP_PASSWORD)
            server.send_message(msg)

    except Exception:
        logger.error(
            "Failed to send alert email via Outlook SMTP",
            exc_info=True,
        )
