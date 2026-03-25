import json
import requests

from app.core.config import (
    GUPSHUP_API_KEY,
    GUPSHUP_SOURCE,
    GUPSHUP_TEMPLATE_NAME,
)
from app.cache.alert_cache import ALERT_PHONES
from app.core.logger import logger


def send_whatsapp_alert(
    device_id: str,
    location: str,
    temperature: str,
    humidity: str,
    timestamp: str,
) -> None:
    if not ALERT_PHONES:
        return

    url = "https://api.gupshup.io/sm/api/v1/msg"

    headers = {
        "apikey": GUPSHUP_API_KEY,
        "Content-Type": "application/x-www-form-urlencoded",
    }

    template_payload = {
        "id": GUPSHUP_TEMPLATE_NAME,
        "params": [
            device_id,
            location,
            temperature,
            humidity,
            timestamp,
        ],
    }

    for phone in ALERT_PHONES:
        data = {
            "channel": "whatsapp",
            "source": GUPSHUP_SOURCE,
            "destination": phone,
            "message": json.dumps(template_payload),
            "src.name": "ServerWatcher",
        }

        try:
            resp = requests.post(
                url,
                headers=headers,
                data=data,
                timeout=10,
            )

            if resp.status_code != 202:
                logger.error(
                    "Failed to send WhatsApp alert",
                    extra={
                        "phone": phone,
                        "status_code": resp.status_code,
                        "response": resp.text,
                    },
                )

        except Exception:
            logger.error(
                "Exception while sending WhatsApp alert via Gupshup",
                extra={"phone": phone},
                exc_info=True,
            )
