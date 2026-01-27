import uuid

def generate_device_id() -> str:
    return f"esp-{uuid.uuid4().hex[:12]}"