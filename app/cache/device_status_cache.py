from typing import Dict, Literal

class DeviceState:
    def __init__(
        self,
        last_seen: float,
        firmware: str,
        uptime_sec: float,
        sensor_status: Literal["ok", "dead"],
        state: Literal["alive", "dead"],
        alert_active: bool = False,
        firmware_update: bool = False
    ):
        self.last_seen = last_seen
        self.firmware = firmware
        self.uptime_sec = uptime_sec
        self.sensor_status = sensor_status
        self.state = state
        self.alert_active = alert_active
        self.firmware_update = firmware_update

class DeviceCache:
    def __init__(self):
        self._devices: Dict[str, DeviceState] = {}

DEVICECACHE: DeviceCache = DeviceCache()