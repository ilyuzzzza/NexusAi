@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo  ================================
echo   Nexus — diagnose backend
echo  ================================
echo.

REM 1) Is something already on port 8000?
echo  [1/4] Checking port 8000...
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul
if !errorlevel! equ 0 (
    echo        Port 8000 is BUSY:
    netstat -ano | findstr ":8000" | findstr "LISTENING"
    echo        ^(this is fine if it's the backend; otherwise kill that PID^)
) else (
    echo        Port 8000 is FREE — backend is NOT running.
)
echo.

REM 2) Does the venv exist?
echo  [2/4] Checking venv...
if not exist "backend\venv\Scripts\python.exe" (
    echo        venv MISSING — run start.bat first to create it.
    pause
    exit /b 1
)
echo        venv OK
echo.

REM 3) Is edge-tts installed in the venv?
echo  [3/4] Checking edge-tts in venv...
"backend\venv\Scripts\python.exe" -c "import edge_tts; print('        edge-tts OK, version', edge_tts.__version__ if hasattr(edge_tts, '__version__') else '?')" 2>nul
if !errorlevel! neq 0 (
    echo        edge-tts NOT installed — installing now...
    "backend\venv\Scripts\pip.exe" install -r "backend\requirements-local.txt" --disable-pip-version-check
)
echo.

REM 4) Try to import the FastAPI app — surfaces any import-time error.
echo  [4/4] Trying to import the FastAPI app...
cd backend
"venv\Scripts\python.exe" -c "from backend.main import app; print('        backend imports OK')"
if !errorlevel! neq 0 (
    echo.
    echo  ^>^>^> Backend has an IMPORT ERROR. Read it above. ^<^<^<
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

REM 5) Start the backend in the foreground so any crash is visible.
echo  ================================
echo   Starting backend in THIS window
echo   (Ctrl+C to stop)
echo  ================================
echo.
cd backend
"venv\Scripts\python.exe" -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
pause
