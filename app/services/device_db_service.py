import sqlite3
from datetime import datetime, timezone

from app.db.sqlite import get_connection
from app.core.logger import logger


def add_device(
    *,
    device_id: str,
    device_name: str,
    auth_token: str,
) -> None:
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO devices (device_id, device_name, auth_token, created_at)
            VALUES (?, ?, ?, ?)
            """,
            (
                device_id,
                device_name,
                auth_token,
                datetime.now(timezone.utc).isoformat(),
            ),
        )
        conn.commit()

    except sqlite3.IntegrityError as e:
        print("SQLITE ERROR:", e)
        raise

    except Exception:
        logger.error("Failed to add device", exc_info=True)
        raise

    finally:
        conn.close()


def delete_device(*, device_id: str) -> bool:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM devices WHERE device_id = ?",
        (device_id,),
    )

    deleted = cursor.rowcount > 0

    conn.commit()
    conn.close()

    return deleted

def update_device(*, device_id: str, device_name: str) -> bool:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "UPDATE devices SET device_name = ? WHERE device_id = ?",
        (device_name, device_id,),
    )

    updated = cursor.rowcount > 0

    conn.commit()
    conn.close()

    return updated

def count_devices() -> int:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM devices")
    count = cursor.fetchone()[0]

    conn.close()
    return count


def list_devices() -> list[dict]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        SELECT device_id, device_name, created_at
        FROM devices
        ORDER BY created_at DESC
        """
    )

    rows = cursor.fetchall()
    conn.close()

    return [
        {
            "device_id": row[0],
            "device_name": row[1],
            "created_at": row[2],
        }
        for row in rows
    ]

def get_device_name(*, device_id: str) -> str | None:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "SELECT device_name FROM devices WHERE device_id=?",
        (device_id,),
    )

    result = cursor.fetchone()
    conn.close()

    if result:
        return result[0]
    return None