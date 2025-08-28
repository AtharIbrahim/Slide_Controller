# 📱 Slide Controller - Phone as Presentation Remote

Transform your phone into a powerful presentation remote! Control slides on your laptop/PC by swiping on your phone. Perfect for presentations when you want to move away from your computer.

## 🎯 Features

### 📱 **Flutter Mobile App**
- **Swipe Controls**: Swipe left/right to navigate slides
- **Touch Buttons**: Previous/Next slide buttons
- **Real-time Connection**: WebSocket connection to your computer
- **Beautiful UI**: Modern dark theme with animations
- **Connection Status**: Visual feedback for connection state
- **Presentation Mode**: Start/Stop presentation from your phone

### 💻 **Python Server**
- **Cross-Platform**: Works with any presentation software
- **Auto IP Detection**: Automatically finds your computer's IP address
- **Multiple Clients**: Support for multiple connected phones
- **Keyboard Automation**: Uses standard keyboard shortcuts
- **Real-time Communication**: WebSocket server for instant response

## 🚀 Quick Start

### 1. Setup Python Server (Computer)

1. **Navigate to the python_server folder**:
   ```bash
   cd python_server
   ```

2. **Install dependencies** (Windows):
   ```bash
   # Double-click install.bat OR run:
   pip install -r requirements.txt
   ```

3. **Start the server**:
   ```bash
   # Double-click start_server.bat OR run:
   python slide_controller_server.py
   ```

4. **Note the IP address** displayed (e.g., `192.168.1.100`)

### 2. Setup Flutter App (Phone)

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Connect to your computer**:
   - Enter the IP address from step 1.4
   - Tap "Connect"

### 3. Control Your Presentation

1. **Open your presentation** (PowerPoint, Google Slides, etc.)
2. **Tap "Start"** in the app to begin presentation mode
3. **Swipe left/right** or use buttons to control slides
4. **Tap "End"** to exit presentation mode

## 🛠️ Technologies Used

### Frontend (Flutter)
- **Flutter & Dart**: Cross-platform mobile development
- **BLoC Pattern**: State management architecture
- **WebSocket**: Real-time communication
- **Flutter Animate**: Smooth animations
- **Material Design 3**: Modern UI components

### Backend (Python)
- **WebSockets**: Real-time bidirectional communication
- **PyAutoGUI**: Keyboard automation
- **AsyncIO**: Asynchronous server handling
- **JSON**: Data serialization

## 📋 Supported Presentation Software

✅ **Microsoft PowerPoint**  
✅ **Google Slides** (Browser)  
✅ **LibreOffice Impress**  
✅ **Apple Keynote**  
✅ **PDF Viewers** (Adobe Reader, etc.)  
✅ **Any software that supports arrow key navigation**

## 🎮 Controls

### Phone App
- **Swipe Right**: Previous slide
- **Swipe Left**: Next slide
- **Previous Button**: Go to previous slide
- **Next Button**: Go to next slide
- **Start Button**: Begin presentation (F5)
- **End Button**: Exit presentation (Esc)

### Keyboard Shortcuts Used
- **F5**: Start presentation
- **Esc**: End presentation
- **Right Arrow**: Next slide
- **Left Arrow**: Previous slide

## 🔧 Architecture

### Flutter App (BLoC Pattern)
```
lib/
├── bloc/
│   ├── slide_controller_bloc.dart    # Main business logic
│   └── slide_controller_event.dart   # Events
├── models/
│   ├── slide_controller_state.dart   # App state
│   └── slide_command.dart           # Command definitions
├── services/
│   └── slide_controller_service.dart # WebSocket service
├── screens/
│   └── slide_control_screen.dart    # Main UI screen
└── main.dart                        # App entry point
```

### Python Server
```
python_server/
├── slide_controller_server.py       # Main server
├── requirements.txt                 # Dependencies
├── install.bat                     # Windows installer
├── start_server.bat               # Windows launcher
└── README.md                      # Server documentation
```

## 🌐 Network Requirements

- **Same WiFi Network**: Both devices must be connected to the same network
- **Port 8080**: Server runs on port 8080 (configurable)
- **Firewall**: Ensure port 8080 is not blocked

## 🔒 Security

- **Local Network Only**: Server only accepts local network connections
- **No Internet Required**: Works completely offline
- **Minimal Permissions**: Only requires keyboard automation access

## 🐛 Troubleshooting

### Connection Issues
```bash
# Check if devices are on same network
# Windows: ipconfig
# Mac/Linux: ifconfig

# Test server connectivity
ping [SERVER_IP]
```

### App Not Responding to Swipes
- Ensure presentation software window is in focus
- Try clicking on the presentation before using remote
- Check if presentation is in fullscreen mode

### Python Server Issues
```bash
# Reinstall dependencies
pip install --upgrade -r requirements.txt

# Check Python version (3.7+ required)
python --version
```

## 🎨 Customization

### Change Keyboard Shortcuts
Edit `slide_controller_server.py`:
```python
def next_slide(self):
    pyautogui.press('space')  # Change to spacebar

def previous_slide(self):
    pyautogui.press('backspace')  # Change to backspace
```

### Modify App Theme
Edit `lib/main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.purple,  // Change primary color
    brightness: Brightness.dark,
  ),
),
```

## 📱 App Screenshots

*Connection Screen*: Enter your computer's IP address  
*Control Screen*: Swipe or tap to control slides  
*Presentation Mode*: Visual slide counter and controls  

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 💡 Future Enhancements

- [ ] Laser pointer simulation
- [ ] Slide thumbnails preview
- [ ] Timer and notes display
- [ ] Multiple presentation support
- [ ] Gesture customization
- [ ] Voice commands
- [ ] Slide annotations

---

## 🚀 Getting Started Now!

1. **Clone this repository**
2. **Follow the Quick Start guide above**
3. **Start presenting like a pro!** 🎯

**Enjoy your wireless presentation experience!** 📱➡️💻
