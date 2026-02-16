from pathlib import  Path
from app.core.config import SERVER_HOST, SERVER_PORT, FIRMWARE_VERSION

FIRMWARE_TEMPLATE = Path("app/firmware/firmware_template.ino")

def generate_firmware(
    *,
    device_id: str,
    auth_token: str
) -> str:
    template = FIRMWARE_TEMPLATE.read_text()

    return (
        template
        .replace("{{DEVICE_ID}}", device_id)
        .replace("{{AUTH_TOKEN}}", auth_token)
        .replace("{{FIRMWARE_VERSION}}", str(FIRMWARE_VERSION))
        .replace("{{SERVER_HOST}}", str(SERVER_HOST))
        .replace("{{SERVER_PORT}}", str(SERVER_PORT))
        .replace("{{INGEST_PATH}}", "/ingest")
        .replace("{{STATUS_PATH}}", "/status")
    )