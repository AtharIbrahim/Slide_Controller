#!/usr/bin/env python3
"""
Quick test script to verify the Python environment and dependencies
for the Slide Controller Server.
"""

import sys
import importlib.util

def check_python_version():
    """Check if Python version is 3.7 or higher"""
    version = sys.version_info
    if version.major == 3 and version.minor >= 7:
        print(f"✅ Python {version.major}.{version.minor}.{version.micro} - OK")
        return True
    else:
        print(f"❌ Python {version.major}.{version.minor}.{version.micro} - Need Python 3.7+")
        return False

def check_package(package_name):
    """Check if a package is installed"""
    spec = importlib.util.find_spec(package_name)
    if spec is not None:
        print(f"✅ {package_name} - Installed")
        return True
    else:
        print(f"❌ {package_name} - Not installed")
        return False

def main():
    print("=" * 50)
    print("🔍 SLIDE CONTROLLER SERVER - ENVIRONMENT CHECK")
    print("=" * 50)
    
    # Check Python version
    python_ok = check_python_version()
    
    # Check required packages
    packages = ['websockets', 'pyautogui', 'asyncio', 'json', 'logging', 'socket']
    all_packages_ok = True
    
    print("\n📦 Checking required packages:")
    for package in packages:
        if not check_package(package):
            all_packages_ok = False
    
    print("\n" + "=" * 50)
    if python_ok and all_packages_ok:
        print("🎉 ALL CHECKS PASSED!")
        print("✅ Your environment is ready to run the Slide Controller Server")
        print("\nTo start the server, run:")
        print("   python slide_controller_server.py")
    else:
        print("❌ SOME CHECKS FAILED!")
        print("Please install missing dependencies:")
        print("   pip install -r requirements.txt")
    
    print("=" * 50)

if __name__ == "__main__":
    main()
