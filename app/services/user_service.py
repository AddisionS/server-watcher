import sqlite3
from app.core.logger import logger
from app.core.security import hash_password
from app.db.sqlite import get_connection

def add_user(*, username: str, password: str, role: str) -> None:
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO users (username, password, role)
            VALUES (?, ?, ?)
            """,
            (
                username,
                hash_password(password),
                role,
            ),
        )
        conn.commit()

    except sqlite3.IntegrityError:
        raise ValueError("User already exists")

    except Exception:
        logger.error("Failed to add user", exc_info=True)
        raise

    finally:
        conn.close()



def get_user(username: str) -> dict | None:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        SELECT username, password, role
        FROM users
        WHERE username = ?
        """,
        (username,),
    )

    row = cursor.fetchone()
    conn.close()

    if not row:
        return None

    return {
        "username": row[0],
        "password": row[1],
        "role": row[2],
    }


def delete_user(*, username: str) -> None:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM users WHERE username = ?",
        (username,),
    )

    conn.commit()
    conn.close()


def list_users() -> list[dict]:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "SELECT username, role FROM users ORDER BY username"
    )

    rows = cursor.fetchall()
    conn.close()

    return [
        {
            "username": row[0],
            "role": row[1],
        }
        for row in rows
    ]
