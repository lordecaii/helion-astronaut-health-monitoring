@echo off
REM HELION baslatici (Windows): eski sunucuyu kapatir, yenisini acar, tarayiciyi acar.
cd /d %~dp0
set PORT=8020
echo HELION baslatiliyor: http://localhost:%PORT%
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%PORT% ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
timeout /t 1 >nul
start "" /min py -m http.server %PORT%
timeout /t 2 >nul
start "" http://localhost:%PORT%
