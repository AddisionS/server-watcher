from datetime import datetime, timezone
import sqlite3

from app.db.sqlite import get_connection
from app.core.alert_cache import ALERT_EMAILS, ALERT_PHONES
from app.core.logger import logger


def load_alert_contacts() -> None:
    ALERT_EMAILS.clear()
    ALERT_PHONES.clear()

    with get_connection() as conn:
        cursor = conn.cursor()

        cursor.execute("SELECT email FROM alert_emails")
        for (email,) in cursor.fetchall():
            ALERT_EMAILS.add(email)

        cursor.execute("SELECT phone FROM alert_phones")
        for (phone,) in cursor.fetchall():
            ALERT_PHONES.add(phone)



def add_alert_email(email: str) -> None:
    try:
        with get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO alert_emails (email, created_at)
                VALUES (?, ?)
                """,
                (email, datetime.now(timezone.utc).isoformat()),
            )
            conn.commit()

        ALERT_EMAILS.add(email)

    except sqlite3.IntegrityError:
        ALERT_EMAILS.add(email)

    except Exception:
        logger.error(
            "Failed to add alert email",
            extra={"email": email},
            exc_info=True,
        )
        raise


def remove_alert_email(email: str) -> None:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM alert_emails WHERE email = ?",
            (email,),
        )
        conn.commit()

    ALERT_EMAILS.discard(email)


def add_alert_phone(phone: str) -> None:
    try:
        with get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO alert_phones (phone, created_at)
                VALUES (?, ?)
                """,
                (phone, datetime.now(timezone.utc).isoformat()),
            )
            conn.commit()

        ALERT_PHONES.add(phone)

    except sqlite3.IntegrityError:
        ALERT_PHONES.add(phone)

    except Exception:
        logger.error(
            "Failed to add alert phone",
            extra={"phone": phone},
            exc_info=True,
        )
        raise


def remove_alert_phone(phone: str) -> None:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM alert_phones WHERE phone = ?",
            (phone,),
        )
        conn.commit()

    ALERT_PHONES.discard(phone)
