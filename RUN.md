# HastKala - Run Commands

## Backend (FastAPI - Python)

### Setup (First Time)
```bash
cd backend

# Create virtual environment
python -m venv .venv

# Activate virtual environment (Windows)
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up .env file (copy from .env.example or create manually)
# Required: SUPABASE_URL, SUPABASE_SECRET_KEY, APP_NAME, APP_VERSION
```

### Run Backend
```bash
cd backend

# Activate virtual environment
.venv\Scripts\activate

# Run development server (with auto-reload)
uvicorn app.main:app --reload

# Run on specific host and port
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Run in production mode (without auto-reload)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Backend Endpoints
| Method | URL | Description |
|--------|-----|-------------|
| GET | http://127.0.0.1:8000/ | Root message |
| GET | http://127.0.0.1:8000/health | Health check |
| GET | http://127.0.0.1:8000/health/supabase | Supabase health |
| GET | http://127.0.0.1:8000/docs | API Documentation (Swagger) |
| GET | http://127.0.0.1:8000/redoc | API Documentation (ReDoc) |

---

## Frontend / Mobile App (Flutter)

### Setup (First Time)
```bash
cd mobile

# Get dependencies
flutter pub get

# Check Flutter installation
flutter doctor

# Generate platform-specific files (if needed)
flutter create .
```

### Run on Different Platforms
```bash
cd mobile

# Run on connected device / emulator
flutter run

# Run on Windows desktop
flutter run -d windows

# Run on Chrome (web)
flutter run -d chrome

# Run on Edge (web)
flutter run -d edge

# Run on Android emulator
flutter run -d android

# Run on iOS simulator (macOS only)
flutter run -d ios

# List all available devices
flutter devices
```

### Flutter Build Commands
```bash
cd mobile

# Build APK (Android)
flutter build apk

# Build App Bundle (Android - for Play Store)
flutter build appbundle

# Build Web
flutter build web

# Build Windows
flutter build windows

# Build with release mode
flutter build apk --release
```

### Flutter Debug Commands
```bash
cd mobile

# Hot reload (while running)
r

# Hot restart (while running)
R

# Quit app
q

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Clean build files
flutter clean

# Upgrade dependencies
flutter pub upgrade

# Get dependency version info
flutter pub deps
```

---

## Quick Start

### Backend Only
```bash
cd backend
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Mobile App Only
```bash
cd mobile
flutter pub get
flutter run
```

### Both Together
```bash
# Terminal 1 - Backend
cd backend
.venv\Scripts\activate
uvicorn app.main:app --reload

# Terminal 2 - Mobile App
cd mobile
flutter run -d windows
```

---

## Environment Variables (.env)
Create `.env` file in `backend/` folder:
```env
APP_NAME=HastKala
APP_VERSION=1.0.0
SUPABASE_URL=your_supabase_url_here
SUPABASE_SECRET_KEY=your_supabase_secret_key_here
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `pip` not recognized | Use `python -m pip install -r requirements.txt` |
| Virtual env not activating | Run `.venv\Scripts\activate.bat` or restart terminal |
| Flutter not found | Run `flutter doctor` to check installation |
| Device not detected | Run `flutter devices` and use device ID with `-d` |
| Port 8000 in use | Use `uvicorn app.main:app --port 8001` |
