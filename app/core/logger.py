import logging
from pathlib import Path
from app.core.config import LOGS_PATH

LOG_DIR = Path(LOGS_PATH)

LOG_FILE = LOG_DIR / "serverwatcher.log"

logger = logging.getLogger("serverwatcher")
logger.setLevel(logging.INFO)

formatter = logging.Formatter(
    "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
)

file_handler = logging.FileHandler(LOG_FILE)
file_handler.setFormatter(formatter)

console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(console_handler)
