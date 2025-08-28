import socket
import subprocess
import platform

def get_network_info():
    """Get detailed network information"""
    print("=" * 60)
    print("🔍 NETWORK DIAGNOSTIC TOOL")
    print("=" * 60)
    
    # Get local IP
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        print(f"📱 Computer IP Address: {local_ip}")
        print(f"🌐 Server URL: ws://{local_ip}:8080")
    except Exception as e:
        print(f"❌ Error getting IP: {e}")
    
    print("\n📶 Network Interfaces:")
    
    # Windows network info
    if platform.system() == "Windows":
        try:
            result = subprocess.run(['ipconfig'], capture_output=True, text=True)
            lines = result.stdout.split('\n')
            current_adapter = ""
            
            for line in lines:
                line = line.strip()
                if "adapter" in line and ":" in line:
                    current_adapter = line
                    print(f"\n🔌 {current_adapter}")
                elif "IPv4 Address" in line and "192.168" in line:
                    ip = line.split(":")[-1].strip()
                    print(f"   📍 IP: {ip}")
                elif "Subnet Mask" in line:
                    mask = line.split(":")[-1].strip()
                    print(f"   🎭 Mask: {mask}")
        except Exception as e:
            print(f"❌ Error getting network info: {e}")
    
    print("\n" + "=" * 60)
    print("📋 TROUBLESHOOTING CHECKLIST:")
    print("=" * 60)
    print("1. ✅ Make sure both devices are on SAME WiFi network")
    print("2. ✅ Use the IP address shown above in your Flutter app")
    print("3. ✅ Check if Windows Firewall is blocking port 8080")
    print("4. ✅ Try temporarily disabling antivirus/firewall")
    print("5. ✅ Restart your WiFi router if needed")
    print("6. ✅ Make sure your phone is connected to WiFi (not mobile data)")
    print("=" * 60)
    
    print("\n🔧 QUICK FIXES:")
    print("• If using WiFi extender, connect both to main router")
    print("• Check if your network has AP isolation enabled")
    print("• Try using hotspot from phone and connect computer to it")
    print("• Test with a simple ping first")
    print("=" * 60)

if __name__ == "__main__":
    get_network_info()
