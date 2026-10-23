# HastKala — Run Guide

Sirf **2 `.env` files** hain. IP sirf ek jagah badalta hai.

| File | Kya rakha hai | Kab badalte ho |
|------|---------------|----------------|
| `mobile/.env` | `API_MODE`, `BACKEND_URL`, `BACKEND_IP`, `BACKEND_PORT`, `GROQ_API_KEY` | Backend badalne pe (local/Render) ya IP change pe |
| `backend/.env` | Supabase, Groq/Deepgram keys, port, CORS | Pehli baar setup + key badalne pe |

> Backend `0.0.0.0` pe bind hota hai, isliye **backend me IP ki zaroorat nahi** — IP/URL sirf `mobile/.env` me jaata hai.

---

## 1. Prerequisites (ek baar install karo)

- **Flutter 3.x** → `flutter doctor` se check karo
- **Python 3.11+** → `python --version`
- **Supabase project** (free tier chalega) → URL + keys chahiye
- PC aur phone **same Wi-Fi network** pe ho (physical device ke liye)

---

## 2. First Time Setup

> Shortcut: root pe `run-backend.bat` double-click kar do — venv, deps aur `.env` ka kaam khud kar deta hai (neeche ka manual tabhi zaroori jab kuch customize karna ho).

### Backend

```powershell
cd backend

# virtual environment banao (sirf pehli baar)
python -m venv .venv
.\.venv\Scripts\activate

# dependencies install karo (sirf pehli baar)
python -m pip install -r requirements.txt

# env file banao (sirf pehli baar)
copy .env.example .env
```

Ab `backend/.env` me ye zaroori values bhar do:

```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
SUPABASE_SECRET_KEY=sb_secret_...
GROQ_API_KEY=gsk_...
DEEPGRAM_API_KEY=...
```

Optional: `OLLAMA_BASE_URL=http://localhost:11434` agar locally Ollama chal raha hai, warna khali chhodo.

macOS/Linux users: activate command `source .venv/bin/activate`, copy command `cp .env.example .env`.

### Mobile (Flutter)

```powershell
cd mobile

flutter doctor        # installation check
flutter pub get       # dependencies (sirf pehli baar)
```

`mobile/.env` already exist karta hai — 3 cheezein set hoti hain:

```env
# API_MODE: auto = local pehle, nahi mila toh Render | local = sirf PC | prod = sirf Render
API_MODE=auto

# Deployed backend (Render)
BACKEND_URL=https://hastkala-0zlv.onrender.com

# PC ka LAN IP — physical phone ke liye local backend (ipconfig se dekho)
BACKEND_IP=192.168.1.44
BACKEND_PORT=8000
```

```powershell
ipconfig     # "IPv4 Address" line dekho, e.g. 192.168.1.44
```

---

## 3. Har Bar Kaise Run Karte Hain

### Ek command (recommended)

Root pe 3 scripts hain — terminal se ya double-click:

| Command | Kya karta hai |
|---------|---------------|
| `run-backend.bat` | Backend start (`--reload`, port 8000). Venv auto-activate, **pehli baar setup bhi khud karega** |
| `run-app.bat` | Flutter app run (`run-app.bat -d windows` jaise args bhi chalega) |
| `dev.bat` | Backend ek naye window me + app isi window me — **dono ek saath** |

```bat
run-backend.bat      :: sirf backend
dev.bat              :: backend + mobile app, ek hi command
```

- Server: `http://127.0.0.1:8000` → Swagger: `http://127.0.0.1:8000/docs`
- Pehli baar launch pe AI model load hota hai (~30–40s), uske baad turant
- Backend band = same window me `Ctrl+C` (ya backend window band)

### Manual (scripts ka hi underlying command)

**Terminal 1 — Backend**

```powershell
cd backend
.\.venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 — Mobile**

```powershell
cd mobile
flutter devices        # available devices dekho
flutter run            # default device
# ya specific device:
flutter run -d <device-id>
```

### Platform ke hisaab se

```powershell
cd mobile

flutter run -d windows      # Windows desktop
flutter run -d chrome       # Web (Chrome)
flutter run -d android      # Android emulator (10.0.2.2 auto-use hota hai)
flutter run -d ios          # iOS simulator (macOS only)
```

---

## 4. Backend Kaise Choose Hota Hai (`API_MODE`)

**Abhi `mobile/.env` me `API_MODE=local` set hai — sirf PC backend use hota hai (Render wala hissa idle).**

Aage kabhi switch karna ho toh sirf `mobile/.env` edit karo:

| `API_MODE` | Kab use karo | Kya hota hai |
|------------|--------------|--------------|
| `local` (abhi) | PC + phone same Wi-Fi pe | Hamesha `BACKEND_IP:BACKEND_PORT` |
| `auto` | Kabhi local, kabhi Render | Launch pe local `/health` check (≤2s) → healthy toh PC backend; nahi toh Render |
| `prod` | Demo / phone se bina PC ke | Hamesha `BACKEND_URL` (Render) |

```env
# mobile/.env — backend badalne ke liye yahi line
API_MODE=local
```

Notes:
- `.env` build me bake hota hai → badalne ke baad `flutter run` / APK dobara build karo (hot-reload `r` se nahi badlega).
- `auto`/`prod` me launch pe Render ka health call jaata hai — free tier so raha ho toh pehli baar **30–60s** lag sakte hain. `local` mode me aisa kuch nahi, seedha PC backend.

### IP Change (physical phone, local backend ke liye)

1. `ipconfig` se PC ka naya LAN IP nikalo
2. Sirf **`mobile/.env`** me `BACKEND_IP=` update karo
3. App dobara run karo (`flutter run`)

---

## 5. APK Kaise Banaye / Phone Pe Chalaye

### Debug APK (development — phone USB se connected)

```powershell
cd mobile
flutter devices               # device id dekho
flutter run                   # directly phone pe run (hot reload ke saath)
# ya:
flutter run -d <device-id>
```

### APK file banao aur install karo

```powershell
cd mobile

flutter build apk --debug                # build\app\outputs\flutter-apk\app-debug.apk
flutter build apk --release              # release APK (phone ko "install blocked" dikhe toh debug use karo)

# device connected ho toh directly install:
flutter install

# ya manually (adb):
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

### Deployed backend ke saath sirf APK chahiye (local backend band)

```powershell
cd mobile

# .env me API_MODE=prod karke build
flutter build apk --debug
flutter install

# ya ek command me (file edit bhi nahi):
flutter run --dart-define=API_MODE=prod --dart-define=BACKEND_URL=https://hastkala-0zlv.onrender.com
```

`--dart-define` wala build `.env` override kar deta hai — CI/demo ke liye best.

---

## 6. Backend Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | http://127.0.0.1:8000/ | Root message |
| GET | http://127.0.0.1:8000/health | Health check |
| GET | http://127.0.0.1:8000/health/supabase | Supabase health |
| GET | http://127.0.0.1:8000/docs | Swagger UI |
| GET | http://127.0.0.1:8000/redoc | ReDoc |

---

## 7. Common Commands

### Backend

```powershell
cd backend
.\.venv\Scripts\activate

uvicorn app.main:app --reload                              # dev (auto-reload)
uvicorn app.main:app --host 0.0.0.0 --port 8000            # LAN par accessible
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 1  # production style

python -m pip install -r requirements.txt                  # deps update
python -m pip install pytest                               # tests ke liye (pehli baar)
python -m pytest                                           # tests
```

### Mobile

```powershell
cd mobile

flutter analyze          # code issues check
flutter test             # tests
flutter clean            # build cache clear (galat IP/API dikh raha ho to)
flutter pub get          # deps dobara resolve
flutter pub upgrade      # deps upgrade
```

**Run ke beech (terminal me):** `r` = hot reload, `R` = hot restart, `q` = quit

### Builds

```powershell
cd mobile

flutter build apk --release          # Android APK
flutter build appbundle --release    # Play Store
flutter build web                    # Web
flutter build windows                # Windows
```

---

## 8. Troubleshooting

| Issue | Solution |
|-------|----------|
| Phone backend tak nahi pahunch raha | Same Wi-Fi check karo, `mobile/.env` ka `BACKEND_IP` update karo, `ipconfig` se verify karo |
| Purana IP/IP nahi badla | `flutter clean` → `flutter pub get` → `flutter run` |
| `pip` not recognized | `python -m pip install -r requirements.txt` use karo |
| Virtual env activate nahi ho raha | `.venv\Scripts\activate.bat` chalao ya terminal restart karo |
| `flutter` not found | `flutter doctor` chalao, PATH check karo |
| Device detect nahi ho raha | `flutter devices`, phir `flutter run -d <id>` |
| Port 8000 already in use | `netstat -ano \| findstr :8000` se PID dekho, ya `--port 8001` use karo (aur `mobile/.env` me `BACKEND_PORT` bhi) |
| Supabase auth 401 de raha hai | `backend/.env` me `SUPABASE_SECRET_KEY` sahi hai ya nahi |
| Pehli baar boot slow | `PRELOAD_AI_MODEL=True` rembg model (~180MB) download karta hai; dev me `False` rakh sakte ho |
| Desktop/Web pe connect nahi ho raha | Backend chal raha hai? `http://127.0.0.1:8000/health` browser me kholo |
| Pata nahi kaunsa backend use ho raha hai | App launch ke console me `ApiConfig: mode=... base=...` line dekho |
| App launch pe 30–60s rukta hai | Normal hai jab `API_MODE=auto/prod` aur Render so raha hai (free tier cold start). Local backend on karke `auto` rakhoge toh turant khulega |
| Render pe timeout/502 aata hai | Browser me `https://hastkala-0zlv.onrender.com/health` kholo; agar na khule toh Render dashboard → service status/logs dekho (deploy fail ya paused ho sakta hai) |
| Render chahiye tha par purana local backend lag raha hai | `API_MODE=auto` local ko priority deta hai — `API_MODE=prod` karke dobara build karo |
| Galat `BACKEND_URL` | `mobile/.env` me URL `https://` ke saath, bina trailing `/` ke |

---

## 9. Deploy (Render)

`render.yaml` root me hai — non-secret values (`HOST`, `DEBUG`, `CORS_ORIGINS`, `PRELOAD_AI_MODEL=false`, `OLLAMA_BASE_URL=""`, `GROQ_MODEL`) usme already set hain. Sirf **secret values** Render dashboard me daalni hain (wo `sync: false` marked hain):

- `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWKS_URL`
- `GROQ_API_KEY`, `DEEPGRAM_API_KEY`
- `PUBLIC_BASE_URL=https://<your-service>.onrender.com` (first deploy ke baad)

Koi code change nahi chahiye. Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 1`

Deploy ke baad health check (browser/curl):

```
https://hastkala-0zlv.onrender.com/health   -> {"status":"healthy"}
https://hastkala-0zlv.onrender.com/docs
```

Yahi URL `mobile/.env` ke `BACKEND_URL` me hota hai.
