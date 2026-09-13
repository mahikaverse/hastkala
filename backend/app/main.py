import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from pathlib import Path
from fastapi.staticfiles import StaticFiles

from app.api.ai import get_remove_session, router as ai_router
from app.api.transcribe import router as transcribe_router
from app.api.extract import router as extract_router
from app.api.pricing import router as pricing_router
from app.api.voice_to_catalog import router as voice_to_catalog_router
from app.api.auth import router as auth_router
from app.api.products import router as products_router
from app.api.stream_stt import router as stream_stt_router
from app.api.b2b import router as b2b_router
from app.api.marketing import router as marketing_router
from app.api.marketplace_prep import router as marketplace_prep_router
from app.core.config import settings
from app.core.supabase import get_supabase

logger = logging.getLogger("hastkala")
logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
)

# Static files mount for local uploads fallback
uploads_dir = Path(__file__).resolve().parent.parent / "data" / "uploads"
uploads_dir.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai_router)
app.include_router(transcribe_router)
app.include_router(extract_router)
app.include_router(voice_to_catalog_router)
app.include_router(pricing_router)
app.include_router(auth_router)
app.include_router(products_router)
app.include_router(stream_stt_router)
app.include_router(b2b_router)
app.include_router(marketing_router)
app.include_router(marketplace_prep_router)


@app.on_event("startup")
def startup_event():
    try:
        logger.info("Loading AI model on startup...")
        get_remove_session()
        logger.info("AI model loaded. Server ready!")
    except Exception as e:
        logger.warning(f"Could not preload AI model on startup: {e}")


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
