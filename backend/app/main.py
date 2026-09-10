import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.ai import get_remove_session, router as ai_router
from app.core.config import settings
from app.core.supabase import get_supabase

logger = logging.getLogger("hastkala")
logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai_router)


@app.on_event("startup")
def startup_event():
    logger.info("Loading AI model on startup...")
    get_remove_session()
    logger.info("AI model loaded. Server ready!")


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
