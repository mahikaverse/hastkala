from fastapi import FastAPI

from app.core.config import settings
from app.core.supabase import get_supabase

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
)


@app.get("/")
def root():
    return {"message": "HastKala Backend is running!", "status": "ok"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/health/supabase")
def health_supabase():
    url = settings.SUPABASE_URL
    key = settings.SUPABASE_SECRET_KEY
    if not url or not key:
        return {"status": "unconfigured", "supabase": False}
    try:
        client = get_supabase()
        client.table("_health_check").select("*").limit(1).execute()
        return {"status": "connected", "supabase": True}
    except Exception:
        return {"status": "configured_but_unreachable", "supabase": False}
