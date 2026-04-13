# Server Watcher — Backend

> FastAPI backend for **Server Watcher**, an IoT monitoring system that collects temperature and humidity data from ESP-based devices, evaluates alert thresholds, and dispatches notifications via Email.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Flow](#data-flow)
- [API Reference](#api-reference)
- [Authentication & Roles](#authentication--roles)
- [Database Schema](#database-schema)
- [Alert System](#alert-system)
- [Device State Tracking](#device-state-tracking)
- [Firmware Generation](#firmware-generation)
- [Bootstrap Accounts](#bootstrap-accounts)
- [Configuration](#configuration)
- [Running the Project](#running-the-project)

---

## Overview

Server Watcher is designed to monitor physical environments (e.g., server rooms) using ESP microcontrollers equipped with temperature and humidity sensors. The backend:

- Receives sensor readings from registered ESP devices
- Stores time-series metrics in **InfluxDB**
- Evaluates readings against configurable thresholds
- Fires **email** alerts when thresholds are breached
- Tracks real-time device liveness and firmware state in memory
- Provides a REST API consumed by the frontend dashboard
- Auto-generates pre-configured **Arduino firmware** (`.ino`) for new devices

---

## Architecture

```
ESP Device (Arduino/ESP32)
        │
        │  POST /ingest  (device_id + auth_token + sensor data)
        │  POST /status  (heartbeat / component status)
        ▼
┌─────────────────────────────────┐
│        FastAPI Backend          │
│                                 │
│  ┌─────────────┐  ┌──────────┐ │
│  │  SQLite DB  │  │ InfluxDB │ │
│  │  (devices,  │  │ (metrics,│ │
│  │  users,     │  │  alerts) │ │
│  │  thresholds,│  └──────────┘ │
│  │  contacts)  │               │
│  └─────────────┘               │
│                                 │
│  In-memory Caches:              │
│    DeviceCache  (liveness)      │
│    THRESHOLDS                   │
│    ALERT_EMAILS                 │
│                                 │
│  Alert Engine ──► Email (SMTP)  │
└─────────────────────────────────┘
        │
        │  REST API (JWT-protected)
        ▼
   Frontend Dashboard
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Web framework | FastAPI |
| Time-series DB | InfluxDB v3 (`influxdb-client-3`) |
| Relational DB | SQLite |
| Auth | JWT (`python-jose`), bcrypt (`passlib`) |
| Email | SMTP via `smtplib` (STARTTLS) |
| Config | `python-dotenv` |
| Package manager | `uv` |

---

## Project Structure

```
server-watcher-backend/
├── main.py                          # App entry point, lifespan startup
├── requirements.txt
├── pyproject.toml
└── app/
    ├── api/                         # Route handlers
    │   ├── login.py                 # POST /login
    │   ├── ingest.py                # POST /ingest  (device data)
    │   ├── status.py                # POST /status  (device heartbeat)
    │   │                            # GET  /status/{device_id}
    │   ├── metrics.py               # GET  /metrics/...
    │   ├── alerts.py                # GET  /alerts/...
    │   ├── devices.py               # CRUD /admin/devices/...
    │   ├── admin_users.py           # CRUD /admin/users/...
    │   ├── admin_thresholds.py      # GET/PUT /admin/thresholds/
    │   ├── admin_alert_contacts.py  # CRUD /admin/alerts/emails|phones
    │   └── dev_logs.py              # GET /dev/logs/
    ├── cache/
    │   ├── alert_cache.py           # In-memory sets: ALERT_EMAILS, ALERT_PHONES
    │   ├── device_status_cache.py   # In-memory DeviceCache + DeviceState
    │   └── threshold_cache.py       # In-memory THRESHOLDS dict
    ├── core/
    │   ├── config.py                # Env var loading
    │   ├── security.py              # JWT + bcrypt helpers
    │   ├── deps.py                  # require_role() dependency
    │   ├── roles.py                 # Role enum (ADMIN, USER, DEVELOPER)
    │   └── logger.py                # File + console logger
    ├── db/
    │   ├── sqlite.py                # Connection, init_db(), schema
    │   └── influx.py                # InfluxDB client, write/query helpers
    ├── firmware/
    │   └── firmware_template.ino    # Arduino template for device provisioning
    ├── models/                      # Pydantic request/response schemas
    │   ├── auth.py
    │   ├── contacts.py
    │   ├── device.py
    │   ├── ingest.py
    │   ├── status.py
    │   ├── thresholds.py
    │   └── user.py
    └── services/
        ├── account_bootstrap_service.py   # Seeds default users on startup
        ├── alert_contact_service.py       # Load/add/remove alert emails
        ├── alert_dispatch_service.py      # Dispatches email alerts on threshold breach
        ├── alert_eval_service.py          # Threshold breach evaluation
        ├── alert_read_service.py          # Query alert history from InfluxDB
        ├── device_auth_service.py         # Validates device_id + auth_token
        ├── device_auth_token_service.py   # Generates secure auth tokens
        ├── device_db_service.py           # SQLite CRUD for devices
        ├── device_id_service.py           # Generates esp-<uuid> IDs
        ├── device_state_service.py        # Device liveness tracking + cache sync
        ├── email_service.py               # SMTP email dispatch
        ├── firmware_generation_service.py # Template-based .ino generation
        ├── ingest_service.py              # Writes metrics to InfluxDB
        ├── log_read_service.py            # Reads tail of log file
        ├── metric_services.py             # Queries metrics from InfluxDB
        ├── threshold_service.py           # Load/update thresholds
        └── user_service.py                # SQLite CRUD for users
```

---

## Data Flow

### 1. Device Provisioning

```
Admin: POST /admin/devices/  { device_name }
  → generate device_id  (esp-<12-char-uuid>)
  → generate auth_token (secrets.token_urlsafe(32))
  → render app/firmware/firmware_template.ino with credentials injected
  → save device to SQLite
  → add device to in-memory DeviceCache
  → return .ino file as download
```

### 2. Sensor Data Ingestion

```
ESP Device: POST /ingest
  { device_id, auth_token, temperature, humidity }
  → validate device credentials against SQLite
  → write metric to InfluxDB  (measurement: "metrics")
  → evaluate thresholds:
      if breached:
        → write alert to InfluxDB  (measurement: "alerts")
        → dispatch_alert():
            → send_email()     via SMTP to all ALERT_EMAILS
```

### 3. Device Heartbeat

```
ESP Device: POST /status
  { device_id, auth_token, firmware, uptime_sec, components }
  → validate device credentials
  → update DeviceCache:
      last_seen, firmware, uptime_sec, sensor_status
      firmware_update flag set if firmware != FIRMWARE_VERSION
```

### 4. Device Liveness Loop

```
Background thread (started at app startup):
  every 10 seconds → evaluate_device_state()
    for each device in DeviceCache:
      if now - last_seen > DEVICE_THRESHOLD → state = "dead"
      else                                  → state = "alive"
```

### 5. Frontend Dashboard Queries

```
Authenticated User: GET /metrics/latest/{device_id}
                    GET /metrics/24h/{device_id}              → last 24 hours
                    GET /metrics/export/{device_id}?start=&end=  → CSV
                    GET /alerts/                               → recent alerts
                    GET /alerts/device/{device_id}/csv         → CSV export
                    GET /status/{device_id}                    → live device state
```

---

## API Reference

### Auth

| Method | Path | Roles | Description |
|---|---|---|---|
| `POST` | `/login` | Public | Returns JWT access token |

**Request body:**
```json
{ "username": "string", "password": "string" }
```

**Response:**
```json
{ "access_token": "...", "token_type": "bearer", "role": "admin" }
```

---

### Device Ingestion (Device → Server)

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/ingest` | Device token | Submit temperature & humidity readings |
| `POST` | `/status` | Device token | Send device heartbeat / component status |

**Ingest payload:**
```json
{
  "device_id": "esp-abc123def456",
  "auth_token": "...",
  "temperature": 28.5,
  "humidity": 65.2
}
```

**Status payload:**
```json
{
  "device_id": "esp-abc123def456",
  "auth_token": "...",
  "firmware": "1.0.0",
  "uptime_sec": 3600.0,
  "components": { "sensor": "ok" }
}
```

---

### Metrics

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/metrics/latest/{device_id}` | USER, ADMIN, DEVELOPER | Latest reading for a device |
| `GET` | `/metrics/24h/{device_id}` | USER, ADMIN, DEVELOPER | All readings from the last 24 hours |
| `GET` | `/metrics/export/{device_id}?start=&end=` | USER, ADMIN, DEVELOPER | CSV export of a time range |

---

### Alerts

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/alerts/` | USER, ADMIN, DEVELOPER | Recent alerts (up to 1000) |
| `GET` | `/alerts/device/{device_id}/csv` | USER, ADMIN, DEVELOPER | CSV export of device alerts |

---

### Status

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/status/{device_id}` | USER, ADMIN, DEVELOPER | Live state of a device from in-memory cache |

**Response:**
```json
{
  "state": "alive",
  "last_seen": 1711700000.0,
  "uptime_sec": 3600.0,
  "sensor_status": "ok",
  "alert_active": false,
  "firmware": "1.0.0",
  "firmware_update": false
}
```

---

### Admin — Devices

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/admin/devices/` | USER, ADMIN, DEVELOPER | List all devices |
| `GET` | `/admin/devices/count` | USER, ADMIN, DEVELOPER | Count of registered devices |
| `POST` | `/admin/devices/` | ADMIN, DEVELOPER | Register device, returns `.ino` firmware |
| `PUT` | `/admin/devices/` | ADMIN, DEVELOPER | Rename a device |
| `DELETE` | `/admin/devices/{device_id}` | ADMIN, DEVELOPER | Delete a device |

---

### Admin — Users

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/admin/users/` | ADMIN, DEVELOPER | List all users |
| `POST` | `/admin/users/` | ADMIN, DEVELOPER | Create a user |
| `DELETE` | `/admin/users/{username}` | ADMIN, DEVELOPER | Delete a user (cannot self-delete) |

---

### Admin — Thresholds

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/admin/thresholds/` | USER, ADMIN, DEVELOPER | Get current thresholds |
| `PUT` | `/admin/thresholds/` | ADMIN, DEVELOPER | Update thresholds |

**Threshold payload:**
```json
{
  "temp_min": 18.0,
  "temp_max": 30.0,
  "humidity_min": 40.0,
  "humidity_max": 70.0
}
```

---

### Admin — Alert Contacts

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/admin/alerts/emails` | USER, ADMIN, DEVELOPER | List alert emails |
| `POST` | `/admin/alerts/emails?email=` | ADMIN, DEVELOPER | Add alert email |
| `DELETE` | `/admin/alerts/emails?email=` | ADMIN, DEVELOPER | Remove alert email |

---

### Developer

| Method | Path | Roles | Description |
|---|---|---|---|
| `GET` | `/dev/logs/?lines=200` | DEVELOPER only | Tail of the server log file |

---

## Authentication & Roles

The backend uses **JWT Bearer tokens** (HS256, 60-minute expiry). Every protected route uses the `require_role()` FastAPI dependency which decodes the token and checks the `role` claim.

There are three roles:

| Role | Capabilities |
|---|---|
| `user` | Read metrics, alerts, thresholds, devices, alert contacts, and device status |
| `admin` | Everything `user` can do + create/delete users, devices, contacts, and update thresholds |
| `developer` | Everything `admin` can do + access raw server logs via `/dev/logs/` |

Passwords are hashed with **bcrypt** (72-byte limit enforced).

---

## Database Schema

### SQLite (relational / config data)

**`devices`**
| Column | Type | Notes |
|---|---|---|
| `device_id` | TEXT PK | e.g. `esp-abc123def456` |
| `device_name` | TEXT | Human-readable label |
| `auth_token` | TEXT UNIQUE | Used by device to authenticate |
| `created_at` | TEXT | ISO 8601 UTC |

**`users`**
| Column | Type | Notes |
|---|---|---|
| `username` | TEXT PK | |
| `password` | TEXT | bcrypt hash |
| `role` | TEXT | `user`, `admin`, or `developer` |

**`thresholds`** *(single row, id = 1)*
| Column | Type | Default |
|---|---|---|
| `temp_min` | REAL | 18.0 |
| `temp_max` | REAL | 30.0 |
| `humidity_min` | REAL | 40.0 |
| `humidity_max` | REAL | 70.0 |

**`alert_emails`**
| Column | Type |
|---|---|
| `email` | TEXT PK |
| `created_at` | TEXT |

### InfluxDB (time-series data)

**`metrics`** — every sensor reading  
Tags: `device_id`, `device_name`  
Fields: `temperature`, `humidity`

**`alerts`** — readings that breached a threshold  
Tags: `device_id`, `device_name`  
Fields: `temperature`, `humidity`

---

## Alert System

The alert pipeline is triggered on every ingest:

1. **`alert_eval_service`** checks the in-memory `THRESHOLDS` cache. If temperature or humidity is outside the configured min/max range, a breach is recorded.
2. The breach is written to the InfluxDB `alerts` measurement for historical querying.
3. **`alert_dispatch_service`** sends an **Email** via SMTP STARTTLS to all addresses in `ALERT_EMAILS`.

`ALERT_EMAILS` is an in-memory set loaded from SQLite at startup and kept in sync with write-through updates.

The alert notification format includes: Device ID, Device Name, Temperature, Humidity, and Timestamp.

---

## Device State Tracking

Each registered device has a live state entry in the in-memory **`DeviceCache`** (see `app/cache/device_status_cache.py`). State is updated whenever the device posts to `POST /status` and evaluated every 10 seconds by a background thread.

**`DeviceState` fields:**

| Field | Type | Description |
|---|---|---|
| `state` | `"alive"` / `"dead"` | Determined by liveness loop |
| `last_seen` | `float` | Unix timestamp of last `/status` heartbeat |
| `uptime_sec` | `float` | Device-reported uptime in seconds |
| `sensor_status` | `"ok"` / `"dead"` | Reported by device via `components.sensor` |
| `alert_active` | `bool` | Reserved for future use |
| `firmware` | `str` | Firmware version reported by device |
| `firmware_update` | `bool` | `true` if reported firmware differs from `FIRMWARE_VERSION` |

**Liveness rule:** a device is marked `"dead"` if `now - last_seen > DEVICE_THRESHOLD` (default: 90 seconds). It transitions back to `"alive"` as soon as a heartbeat arrives within the threshold.

The cache is initialised at startup by `sync_device_cache()`, which seeds one entry per device in SQLite. New devices are added to the cache immediately on `POST /admin/devices/`; deleted devices are removed on `DELETE /admin/devices/{device_id}`.

---

## Firmware Generation

When a new device is registered via `POST /admin/devices/`, the backend:

1. Generates a unique `device_id` in the format `esp-<12-char-hex>`.
2. Generates a cryptographically secure `auth_token` using `secrets.token_urlsafe(32)`.
3. Reads `app/firmware/firmware_template.ino` and replaces the following placeholders:

| Placeholder | Value |
|---|---|
| `{{DEVICE_ID}}` | Generated device ID |
| `{{AUTH_TOKEN}}` | Generated auth token |
| `{{FIRMWARE_VERSION}}` | From env `FIRMWARE_VERSION` |
| `{{SERVER_HOST}}` | From env `SERVER_HOST` |
| `{{SERVER_PORT}}` | From env `SERVER_PORT` |
| `{{INGEST_PATH}}` | `/ingest` |
| `{{STATUS_PATH}}` | `/status` |

The resulting `.ino` file is returned directly as a download, ready to flash onto the ESP device — no manual credential editing required.

---

## Bootstrap Accounts

On first startup, three default accounts are seeded if they do not already exist:

| Username | Password | Role |
|---|---|---|
| `serverUSER` | `IUSEserver` | `user` |
| `serverADMIN` | `SUPERVISEDserver` | `admin` |
| `serverGOD` | `DOGserver` | `developer` |

> ⚠️ **Change these credentials immediately in any production deployment.**

---

## Configuration

All configuration is loaded from a `.env` file via `python-dotenv`. Create a `.env` in the project root:

```env
# InfluxDB
INFLUX_URL=http://127.0.0.1:8181
INFLUX_DB=serverwatcher
INFLUX_TOKEN=your-influx-token

# SQLite
SQLITE_PATH=data/serverwatcher.db

# Logging
LOGS_PATH=logs

# JWT (required — app will not start without this)
JWT_SECRET=your-very-secret-key

# SMTP (Email alerts)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your@email.com
SMTP_PASSWORD=your-smtp-password
SMTP_FROM=alerts@example.com

# Firmware
SERVER_HOST=your-server-ip-or-domain
SERVER_PORT=8000
FIRMWARE_VERSION=1.0.0

# Device liveness (seconds before a device is considered dead)
DEVICE_THRESHOLD=90
```

> The app **will throw a `RuntimeError` at startup** if `JWT_SECRET` is not set.

---

## Running the Project

### Prerequisites

- Python 3.11+
- InfluxDB v3 running locally or remotely
- `uv` (recommended) or `pip`

### Install dependencies

```bash
# With uv (recommended)
uv sync

# Or with pip
pip install -r requirements.txt
```

### Start the server

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Interactive API docs

Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

---

## Logging

Logs are written to both **console** and **`logs/serverwatcher.log`** in the format:

```
2025-01-01 12:00:00,000 | INFO | serverwatcher | message
```

The log file can be read via the API by users with the `developer` role (`GET /dev/logs/?lines=200`).