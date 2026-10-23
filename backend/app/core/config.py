from pathlib import Path

from pydantic_settings import BaseSettings

# Always read backend/.env (this file), no matter which folder you launch uvicorn from.
BACKEND_DIR = Path(__file__).resolve().parents[2]
ENV_FILE = BACKEND_DIR / ".env"


class Settings(BaseSettings):
    APP_NAME: str = "HastKala Backend"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False

    # Always bind all interfaces so the server is reachable when deployed
    # (Render, Docker, LAN). Never use 127.0.0.1 in production.
    HOST: str = "0.0.0.0"
    # Render injects its own PORT env var — the value below is only a local default.
    PORT: int = 8000

    # Public origin of this API once deployed, e.g. https://hastkala-api.onrender.com
    # Used to turn relative upload paths into absolute URLs. Empty = relative paths.
    PUBLIC_BASE_URL: str = ""

    # Comma-separated list of allowed browser origins, or "*"
    CORS_ORIGINS: str = "*"

    # Preloading the rembg model downloads ~180MB at boot, which can blow the
    # deployment health-check window. Keep it off in the cloud; it loads lazily
    # on the first image request instead.
    PRELOAD_AI_MODEL: bool = False

    SUPABASE_URL: str = ""
    SUPABASE_PUBLISHABLE_KEY: str = ""
    SUPABASE_SECRET_KEY: str = ""
    SUPABASE_JWKS_URL: str = ""

    # Empty = local Ollama disabled (there is no Ollama on Render).
    # Set to http://localhost:11434 in local .env if you run Ollama locally.
    OLLAMA_BASE_URL: str = ""
    OLLAMA_MODEL: str = "qwen2.5:3b"
    OLLAMA_TIMEOUT: int = 120

    GROQ_API_KEY: str = ""
    GROQ_MODEL: str = "qwen/qwen3.8-27b"

    DEEPGRAM_API_KEY: str = ""

    model_config = {"env_file": str(ENV_FILE), "env_file_encoding": "utf-8"}

    @property
    def cors_origin_list(self) -> list[str]:
        raw = (self.CORS_ORIGINS or "*").strip()
        if raw == "*":
            return ["*"]
        return [o.strip() for o in raw.split(",") if o.strip()]

    @property
    def base_url(self) -> str:
        return (self.PUBLIC_BASE_URL or "").rstrip("/")


settings = Settings()
