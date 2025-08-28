@echo off
echo Installing Python dependencies for Slide Controller Server...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Install requirements
echo Installing required packages...
pip install -r requirements.txt

if %errorlevel% equ 0 (
    echo.
    echo ✅ Installation completed successfully!
    echo.
    echo To start the server, run:
    echo python slide_controller_server.py
    echo.
) else (
    echo.
    echo ❌ Installation failed. Please check the error messages above.
    echo.
)

pause
