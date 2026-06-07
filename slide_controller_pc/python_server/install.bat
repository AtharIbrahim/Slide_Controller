@echo off
echo Installing Python dependencies for Slide Controller Server...
echo.

REM Check if Python is installed
py -3.10 --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python 3.10 launcher is not available
    echo Please install Python 3.10 and ensure the py launcher is available
    pause
    exit /b 1
)

REM Install requirements
echo Installing required packages...
py -3.10 -m pip install -r requirements.txt

if %errorlevel% equ 0 (
    echo.
    echo ✅ Installation completed successfully!
    echo.
    echo To start the server, run:
    echo py -3.10 slide_controller_server.py
    echo.
) else (
    echo.
    echo ❌ Installation failed. Please check the error messages above.
    echo.
)

pause
