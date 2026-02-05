from fastapi import FastAPI
from contextlib import asynccontextmanager

from app.api import ingest, login, admin_users, admin_thresholds, metrics, admin_alert_contacts, alerts, dev_logs
from app.db.sqlite import init_db
from app.services.threshold_service import load_thresholds
from app.services.alert_contact_service import load_alert_contacts
from app.services.user_bootstrap_service import bootstrap_user


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    bootstrap_user()
    load_thresholds()
    load_alert_contacts()
    yield



app = FastAPI(lifespan=lifespan)

app.include_router(ingest.router)
app.include_router(login.router)
app.include_router(admin_users.router)
app.include_router(admin_thresholds.router)
app.include_router(metrics.router)
app.include_router(admin_alert_contacts.router)
app.include_router(alerts.router)
app.include_router(dev_logs.router)
