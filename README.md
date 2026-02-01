# Server Watcher - Firmware

This repository contains the firmware for an **ESP32-based IoT device** that uses **wired Ethernet (W5500)** to periodically send sensor data and device health information to a backend server.

The firmware is designed to be **deterministic, backend-driven, and production-oriented**, avoiding Wi-Fi dependency and unreliable self-reported states.

---

##  Features

- ESP32 + W5500 Ethernet (SPI)
- SHT35 temperature & humidity sensor (I2C)
- 16×2 I2C LCD display
- Periodic sensor data ingestion
- Periodic device status
- Automatic Ethernet link detection
- Simple LCD UX with alternating informational screens
- Backend-issued device ID and auth token
- Designed to scale across multiple devices on the same network

---

##  Architecture Overview

The device follows a **push-based model**:

- The ESP32 does **not wait for commands**
- It **periodically reports**:
  - Sensor data → `/ingest`
  - Device health → `/status`
- The backend determines device liveness using **last-seen timestamps**

> If Ethernet is down, the backend will naturally mark the device offline.

---

##  Hardware Used

| Component | Interface | Notes |
|---------|----------|------|
| ESP32 Dev Board | — | Any ESP32 with SPI + I2C |
| W5500 Ethernet Module | SPI | Wired networking |
| SHT31 Sensor | I2C | Temperature & humidity |
| 16×2 LCD (I2C) | I2C | Status + sensor display |

---

##  Pin Configuration

### I2C Bus (SHT31 + LCD)

| Signal | ESP32 GPIO |
|------|------------|
| SDA  | GPIO 21 |
| SCL  | GPIO 22 |

```cpp
Wire.begin(21, 22);
```

### SPI (W5500)

| Signal | ESP32 GPIO |
|------|------------|
| MOSI  | GPIO 23 |
| MISO  | GPIO 19 |
| SCK  | GPIO 18 |
| CS  | GPIO 5 |
| RST  | GPIO 4 |

```cpp
#define W5500_RST 4
#define W5500_CS  5
```

---

## Configuration (Required)

### Device Identity - Backend Generated

```cpp
const char* DEVICE_ID = "";
const char* AUTH_TOKEN = "";
```

### Firmware Version - Backend Generated

```cpp
const char* FIRMWARE_VERSION = "";
```

### Backend Configuration

```cpp
const char* SERVER_HOST = "";
const int SERVER_PORT = 8000;
const char* INGEST_PATH = "";
const char* STATUS_PATH = "";
```

---

## Timing Behaviour

| Function | Interval |
|----------|----------|
| Data Ingest | 2 seconds |
| Status Update | 5 seconds |
| LCD Message Switch | 20 seconds |

---

## Network Behaviour

- MAC address is derived from ESP32 silicon ID
- DHCP is used for IP assignment
- Ethernet link state is monitored continuously
- HTTP requests are only sent when:
    - Ethernet link is UP
    - Sensor readings are valid

---

## Payload formats

Ingest Payload (`/ingest`)
```json
{
  "device_id": "esp-xxxx",
  "auth_token": "token",
  "temperature": 25.43,
  "humidity": 61.20
}
```

Status Payload (`/status`)
```json
{
  "device_id": "esp-xxxx",
  "auth_token": "token",
  "firmware": "1.0.0",
  "uptime_sec": 12345,
  "components": {
    "sensor": "ok"
  }
}
```

---

## Libraries Required

- Ethernet (W5500 compatible)
- ArduinoHttpClient
- Adafruit SHT31
- LiquidCrystal_I2C
- Wire / SPI (built-in)

---

## Board Selection

ESP32 Dev Module

---
