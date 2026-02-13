from app.db.sqlite import get_connection
from app.services.user_service import add_user

def bootstrap_dev() -> None:
    conn = get_connection()
    cursor = conn.cursor()

    username = "serverGOD"
    password = "DOGserver"
    role = "DEVELOPER"

    cursor.execute(
        """
        SELECT 1
        FROM users
        WHERE username = ?
        LIMIT 1;
        """,
        (username,)
    )

    exists = cursor.fetchone() is not None
    conn.close()

    if not exists:
        add_user(
            username=username,
            password=password,
            role=role
        )

def bootstrap_user() -> None:
    conn = get_connection()
    cursor = conn.cursor()

    username = "serverUSER"
    password = "IUSEserver"
    role = "USER"

    cursor.execute(
        """
        SELECT 1
        FROM users
        WHERE username = ?
        LIMIT 1;
        """,
        (username,)
    )

    exists = cursor.fetchone() is not None
    conn.close()

    if not exists:
        add_user(
            username=username,
            password=password,
            role=role
        )

def bootstrap_admin() -> None:
    conn = get_connection()
    cursor = conn.cursor()

    username = "serverADMIN"
    password = "SUPERVISEDserver"
    role = "ADMIN"

    cursor.execute(
        """
        SELECT 1
        FROM users
        WHERE username = ?
        LIMIT 1;
        """,
        (username,)
    )

    exists = cursor.fetchone() is not None
    conn.close()

    if not exists:
        add_user(
            username=username,
            password=password,
            role=role
        )