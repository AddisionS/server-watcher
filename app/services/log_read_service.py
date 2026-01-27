from pathlib import Path
from app.core.config import LOGS_PATH


LOG_FILE = LOGS_PATH / "serverwatcher.log"


def read_logs(
    *,
    lines: int = 200,
) -> str:
    if not LOG_FILE.exists():
        return ""

    with LOG_FILE.open("r", encoding="utf-8") as f:
        all_lines = f.readlines()

    return "".join(all_lines[-lines:])
