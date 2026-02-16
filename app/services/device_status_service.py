from app.core.config import FIRMWARE_VERSION
from datetime import datetime, timezone

class DeviceStateManager:
    def __init__(self):
        self.devices: dict[str, dict] = {}