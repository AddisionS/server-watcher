import sqlite3
from app.core.config import SQLITE_PATH
from app.core.logger import logger


def get_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(SQLITE_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    try:
        with get_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("""
                CREATE TABLE IF NOT EXISTS devices (
                    device_id TEXT PRIMARY KEY,
                    device_name TEXT NOT NULL,
                    auth_token TEXT NOT NULL UNIQUE,
                    device_location TEXT NOT NULL,
                    created_at  TEXT NOT NULL
                )
            """)

            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    username TEXT PRIMARY KEY,
                    password TEXT NOT NULL,
                    role TEXT NOT NULL
                )
            """)

            cursor.execute("""
                CREATE TABLE IF NOT EXISTS thresholds (
                    id INTEGER PRIMARY KEY CHECK (id = 1),

                    temp_min REAL NOT NULL,
                    temp_max REAL NOT NULL,

                    humidity_min REAL NOT NULL,
                    humidity_max REAL NOT NULL,

                    updated_at TEXT NOT NULL
                )
            """)

            cursor.execute("""
                CREATE TABLE IF NOT EXISTS alert_emails (
                    email TEXT PRIMARY KEY,
                    created_at TEXT NOT NULL
                )
            """)

            cursor.execute("""
                CREATE TABLE IF NOT EXISTS alert_phones (
                    phone TEXT PRIMARY KEY,
                    created_at TEXT NOT NULL
                )
            """)

            conn.commit()

    except Exception:
        logger.error(
            "Failed to initialize SQLite database",
            exc_info=True,
        )
        raise
