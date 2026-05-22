@echo off
title Nexus — Первоначальная установка
echo.
echo  ==========================================
echo    Nexus — Установка зависимостей
echo    (запускается один раз)
echo  ==========================================
echo.

REM ── Проверка Python ──────────────────────────────────────────────
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  [ОШИБКА] Python не найден!
    echo  Установите Python 3.11+ с https://python.org
    echo  При установке отметьте "Add Python to PATH"
    echo.
    pause
    exit /b 1
)
python --version

REM ── Проверка Node.js ─────────────────────────────────────────────
node --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  [ОШИБКА] Node.js не найден!
    echo  Установите Node.js 20+ с https://nodejs.org
    echo.
    pause
    exit /b 1
)
node --version

REM ── Виртуальное окружение Python ─────────────────────────────────
echo.
echo  [1/3] Создаю виртуальное окружение Python...
cd backend
if not exist venv (
    python -m venv venv
)

echo  [2/3] Устанавливаю Python-зависимости...
call venv\Scripts\activate
pip install -r requirements-local.txt --quiet
if %ERRORLEVEL% NEQ 0 (
    echo  [ОШИБКА] Не удалось установить Python-зависимости!
    pause
    exit /b 1
)
call venv\Scripts\deactivate
cd ..

REM ── npm-зависимости фронтенда ─────────────────────────────────────
echo  [3/3] Устанавливаю Node.js-зависимости...
cd frontend
call npm install --silent
if %ERRORLEVEL% NEQ 0 (
    echo  [ОШИБКА] Не удалось установить npm-зависимости!
    pause
    exit /b 1
)
cd ..

echo.
echo  ==========================================
echo    Установка завершена!
echo    Теперь запустите start.bat
echo  ==========================================
echo.
pause
