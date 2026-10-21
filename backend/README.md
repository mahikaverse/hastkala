# HastKala Backend

## Run locally

```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn app.main:app --reload
```

Server runs at http://127.0.0.1:8000

## Deploy on Render

`render.yaml` in the repo root already defines the service (`rootDir: backend`,
start command binds `0.0.0.0` and uses Render's `$PORT`).

1. Push the repo to GitHub/GitLab.
2. Render → **New → Blueprint** → pick the repo. It creates `hastkala-api` for you.
   (Or **New → Web Service**, Runtime: Python, Root Directory: `backend`,
   Build Command: `pip install -r requirements.txt`,
   Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 1`.)
3. In the service **Environment** tab fill the secrets marked `sync: false`:
   `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`,
   `SUPABASE_JWKS_URL`, `GROQ_API_KEY`, `DEEPGRAM_API_KEY`.
4. After the first deploy set `PUBLIC_BASE_URL=https://<your-service>.onrender.com`.
5. Health check: `https://<your-service>.onrender.com/health`, docs at `/docs`.

Notes for the cloud:
- No hardcoded IPs: the server binds `0.0.0.0` and never reads `BACKEND_IP`.
- `OLLAMA_BASE_URL` stays empty on Render (no Ollama there) — Groq is the LLM.
- `PRELOAD_AI_MODEL=false` so the ~180MB rembg model downloads lazily on the
  first image request instead of blocking the deploy health check.
- `data/products.json` and `data/uploads/` live on the instance's ephemeral
  disk (reset on each deploy). Product images are persisted in Supabase Storage.

## Endpoints

| Method | Path     | Description       |
|--------|----------|-------------------|
| GET    | /        | Root message      |
| GET    | /health  | Health check      |

Docs available at http://127.0.0.1:8000/docs
