# Slide Controller 📱🖥️

A wireless presentation control system consisting of a mobile app (Flutter/Dart) that connects to a desktop Python application via WiFi to remotely control PowerPoint presentations, Google Slides, and videos.

## 🚀 Features

- **Wireless Control**: Control presentations remotely via WiFi connection
- **PowerPoint Support**: Navigate through PowerPoint presentations seamlessly
- **Google Slides Integration**: Control Google Slides presentations
- **Video Control**: Play, pause, and navigate through videos
- **IP-Based Connection**: Connect using local network IP address
- **Real-time Communication**: Instant response between mobile and desktop
- **Cross-Platform Mobile**: Flutter app works on both iOS and Android
- **Python Desktop Server**: Lightweight Python application for PC control

## 🏗️ System Architecture

```
📱 Mobile App (Flutter/Dart)  ←→  WiFi Network  ←→  🖥️ Desktop App (Python)
        Client                                           Server
```

The system consists of two components:
1. **Mobile App**: Flutter-based remote control interface
2. **Desktop App**: Python application that receives commands and controls presentations

## 📱 Screenshots

<!-- Add your screenshots here -->
![Connection Setup](Screenshots/Screenshot%202025-08-24%20150110.png)
![Remote Control Interface](Screenshots/Screenshot%202025-08-24%20150358.png)
![Presentation Navigation](Screenshots/Screenshot%202025-08-24%20123751.png)

## 🛠️ Technologies Used

### Mobile App
- **Framework**: Flutter
- **Language**: Dart
- **Platform**: iOS & Android
- **Networking**: HTTP/WebSocket for WiFi communication

### Desktop App
- **Language**: Python
- **Presentation Control**: PyAutoGUI, python-pptx
- **Network Server**: Socket programming or HTTP server
- **OS Integration**: Windows/macOS/Linux compatible

## 📋 Prerequisites

### For Mobile App
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- Android Studio or Xcode for development

### For Desktop App
- Python 3.7 or higher
- Required Python packages (see requirements.txt)
- PowerPoint or Google Slides installed
- Video player (VLC, Windows Media Player, etc.)

## 🚀 Getting Started

### Mobile App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/AtharIbrahim/Slide_Controller.git
   cd Slide_Controller
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the mobile application**
   ```bash
   flutter run
   ```

### Desktop App Setup

1. **Navigate to the Python server directory**
   ```bash
   cd desktop_server  # or wherever your Python app is located
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the desktop server**
   ```bash
   python slide_controller_server.py
   ```

## 🔧 Connection Setup

### Step 1: Start Desktop Server
1. Run the Python application on your PC
2. Note the IP address displayed (e.g., `192.168.1.100`)
3. Ensure the server is listening on the specified port

### Step 2: Connect Mobile App
1. Open the Flutter app on your mobile device
2. Ensure your phone and PC are on the same WiFi network
3. Enter your PC's IP address in the app
4. Tap "Connect" to establish the connection

### Step 3: Start Controlling
- **Presentations**: Navigate slides forward/backward, go to specific slides
- **Videos**: Play, pause, seek, volume control
- **System**: Switch between different presentation software

## 📁 Project Structure

```
Slide_Controller/
├── mobile_app/                 # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── connection_screen.dart
│   │   │   ├── control_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── services/
│   │   │   ├── network_service.dart
│   │   │   └── command_service.dart
│   │   ├── widgets/
│   │   └── models/
│   ├── assets/
│   └── pubspec.yaml
├── desktop_server/             # Python desktop application
│   ├── slide_controller_server.py
│   ├── presentation_controller.py
│   ├── video_controller.py
│   ├── network_handler.py
│   └── requirements.txt
└── README.md
```

## 🎮 Control Features

### Presentation Controls
- ➡️ **Next Slide**: Move to next slide
- ⬅️ **Previous Slide**: Go back to previous slide
- 🏠 **First Slide**: Jump to beginning
- 🔚 **Last Slide**: Jump to end
- 🔢 **Go to Slide**: Navigate to specific slide number
- ⏸️ **Pause Presentation**: Pause/resume slideshow

### Video Controls
- ▶️ **Play/Pause**: Toggle video playback
- ⏭️ **Next**: Skip to next video/chapter
- ⏮️ **Previous**: Go to previous video/chapter
- 🔊 **Volume**: Increase/decrease volume
- ⏩ **Seek**: Fast forward/rewind

### System Controls
- 🖥️ **Screen**: Control display settings
- 🔄 **Switch App**: Change between PowerPoint/Google Slides
- 📱 **Connection Status**: Monitor connection health

## 🌐 Network Communication

The mobile app communicates with the desktop application using:
- **Protocol**: HTTP/WebSocket
- **Port**: Default 8080 (configurable)
- **Commands**: JSON-formatted control messages
- **Response**: Status confirmations and feedback

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart best practices for mobile app
- Follow PEP 8 for Python code
- Test on multiple devices and operating systems
- Document any new features or API changes

## 🐛 Troubleshooting

### Connection Issues
- Ensure both devices are on the same WiFi network
- Verify the correct IP address is being used
- Restart both applications if connection fails

### Control Issues
- Make sure presentation software is open and active
- Check if desktop app has proper permissions
- Verify network connectivity between devices

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Athar Ibrahim**
- Website: [@AtharIbrahim](https://github.com/AtharIbrahim)
- GitHub: [@AtharIbrahimKhalid](https://atharibrahimkhalid.netlify.app/)
- Linkedin: [@AtharIbrahim](https://www.linkedin.com/in/athar-ibrahim-khalid-0715172a2/)

## 🆘 Support

If you encounter any issues:
- Open an issue in this repository
- Check the troubleshooting section above
- Ensure you're using compatible versions of all software

