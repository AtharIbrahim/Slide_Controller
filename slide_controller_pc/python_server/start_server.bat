@echo off
echo Starting Slide Controller Server...
echo.

REM Check if Python is installed
py -3.10 --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python 3.10 launcher is not available
    echo Please install Python 3.10 and ensure the py launcher is available
    pause
    exit /b 1
)

REM Start the server
py -3.10 slide_controller_server.py

pause
