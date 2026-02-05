import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent

INFLUX_URL: str = os.getenv("INFLUX_URL", "http://127.0.0.1:8181")
INFLUX_DB: str = os.getenv("INFLUX_DB", "serverwatcher")

SQLITE_PATH: Path = (
    BASE_DIR / os.getenv("SQLITE_PATH", "data/devices.db")
).resolve()


SQLITE_PATH.parent.mkdir(exist_ok=True)

LOGS_PATH: Path = (
    BASE_DIR / os.getenv("LOGS_PATH", "logs" )
).resolve()


LOGS_PATH.mkdir(parents=True, exist_ok=True)

JWT_SECRET: str | None = os.getenv("JWT_SECRET")
if not JWT_SECRET:
    raise RuntimeError("JWT SECRET missing")

SMTP_HOST: str = os.getenv("SMTP_HOST")
SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
SMTP_USERNAME: str = os.getenv("SMTP_USERNAME")
SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD")
SMTP_FROM: str = os.getenv("SMTP_FROM")

GUPSHUP_API_KEY=os.getenv("GUPSHUP_API_KEY")
GUPSHUP_SOURCE=os.getenv("GUPSHUP_API_KEY")
GUPSHUP_TEMPLATE_NAME=os.getenv("GUPSHUP_API_KEY")