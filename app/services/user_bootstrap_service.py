from app.db.sqlite import get_connection
from app.services.user_service import add_user

def bootstrap_user() -> None:
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
        add_user(username, password, role)
