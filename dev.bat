@echo off
setlocal
REM Backend naye window me, current window me Flutter app
start "HastKala Backend" cmd /k "%~dp0run-backend.bat"
timeout /t 3 /nobreak >nul
cd /d "%~dp0mobile"
flutter run %*
