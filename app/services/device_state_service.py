from app.cache.device_status_cache import DeviceState
from app.services.device_db_service import list_devices
import app.cache.device_status_cache as status_cache
from app.core.logger import logger
from typing import Literal
import time
from app.core.config import FIRMWARE_VERSION, DEVICE_THRESHOLD

def sync_device_cache():
    devices = list_devices()
    db_ids = {d["device_id"] for d in devices}

    cache = status_cache.DEVICECACHE
    if cache is None:
        logger.error("DeviceCache not initialized")
        return
    cache_ids = set(cache._devices.keys())

    to_add = db_ids - cache_ids
    to_remove = cache_ids - db_ids

    for d in to_remove:
        del cache._devices[d]

    for d in to_add:
        cache._devices[d] = DeviceState(
            last_seen=0.0,
            firmware="unknown",
            uptime_sec=0.0,
            sensor_status="dead",
            state="dead",
            alert_active=False,
            firmware_update=False
        )

def add_to_device_cache(*, device_id: str):
    cache = status_cache.DEVICECACHE
    if cache is None:
        logger.error("DeviceCache not initialized")
        return
    if device_id not in cache._devices:
        cache._devices[device_id] = DeviceState(
                last_seen=0.0,
                firmware="unknown",
                uptime_sec=0.0,
                sensor_status="dead",
                state="dead",
                alert_active=False,
                firmware_update=False
        )

def remove_from_device_cache(*, device_id: str):
    cache = status_cache.DEVICECACHE
    if cache is None:
        logger.error("DeviceCache not initialized")
        return
    if device_id in cache._devices:
        del cache._devices[device_id]

def process_device_status(
        *,
        device_id: str,
        firmware_version: str,
        uptime_sec: float,
        sensor: Literal["ok", "dead"]
):
    cache = status_cache.DEVICECACHE
    if cache is None:
        logger.error("DeviceCache not initialized")
        return

    device = cache._devices.get(device_id)
    if device is None:
        logger.error(f"Device: {device_id} not found in device cache")
        return

    now = time.time()
    device.last_seen = now
    device.firmware = firmware_version
    device.uptime_sec = uptime_sec
    device.sensor_status = sensor

    if device.firmware != FIRMWARE_VERSION:
        device.firmware_update = True
    else:
        device.firmware_update = False

def evaluate_device_state():
    cache = status_cache.DEVICECACHE
    if cache is None:
        logger.error("DeviceCache not initialized")
        return

    now = time.time()
    for device in cache._devices.values():
        delta = now - device.last_seen

    if delta > DEVICE_THRESHOLD and device.state != "dead":
        device.state = "dead"
    elif delta <= DEVICE_THRESHOLD and device.state != "alive":
        device.state = "alive"

def liveness_loop():
    while True:
        evaluate_device_state()
        time.sleep(10)

def get_device_status(*, device_id: str):
    cache = status_cache.DEVICECACHE
    if cache is None:
        logger.error("DeviceCache not initialized")
        return

    device = cache._devices.get(device_id)
    if device is None:
        return None

    return {
        "state": device.state,
        "last_seen": device.last_seen,
        "uptime_sec": device.uptime_sec,
        "sensor_status": device.sensor_status,
        "alert_active": device.alert_active,
        "firmware": device.firmware,
        "firmware_update": device.firmware_update
    }