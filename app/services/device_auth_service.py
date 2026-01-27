from app.db.sqlite import get_connection
from app.core.logger import logger

def is_device_authorized(device_id: str, auth_token: str) -> bool:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        SELECT 1 FROM devices
        WHERE device_id = ? AND auth_token = ?
        """,
        (device_id, auth_token),
    )

    result = cursor.fetchone()
    conn.close()

    if result is None:
        logger.warning(f"Unauthorized device attempt: device_id = {device_id}")
        return False

    return True
