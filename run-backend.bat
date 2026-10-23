@echo off
setlocal
cd /d "%~dp0backend"

if not exist ".venv\Scripts\activate.bat" (
  echo [setup] venv nahi mili, bana raha hoon...
  python -m venv .venv
  call .venv\Scripts\activate.bat
  python -m pip install -r requirements.txt
) else (
  call .venv\Scripts\activate.bat
)

echo.
echo Backend chal raha hai -> http://127.0.0.1:8000  (docs: /docs)
echo Band karne ke liye Ctrl+C
echo.
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
