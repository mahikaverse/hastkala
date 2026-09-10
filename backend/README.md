# HastKala Backend

## Setup

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

## Endpoints

| Method | Path     | Description       |
|--------|----------|-------------------|
| GET    | /        | Root message      |
| GET    | /health  | Health check      |

Docs available at http://127.0.0.1:8000/docs
