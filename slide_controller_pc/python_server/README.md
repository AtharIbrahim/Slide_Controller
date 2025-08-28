# Slide Controller - Python Server

This is the Python server component of the Slide Controller project that receives commands from the Flutter mobile app and controls presentation software on your computer.

## Features

- **WebSocket Server**: Real-time communication with the Flutter app
- **Keyboard Automation**: Controls slides using keyboard shortcuts
- **Multi-Client Support**: Multiple phones can connect simultaneously
- **Cross-Platform**: Works with PowerPoint, Google Slides, PDF viewers, etc.
- **Auto IP Detection**: Automatically detects your computer's local IP address

## Installation

1. **Install Python** (3.7 or higher)
2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

## Usage

1. **Start the server**:
   ```bash
   python slide_controller_server.py
   ```

2. **Note the IP address** displayed in the console (e.g., `192.168.1.100`)

3. **Open your presentation** in any presentation software:
   - PowerPoint
   - Google Slides (in browser)
   - LibreOffice Impress
   - PDF viewer
   - Any software that supports standard keyboard shortcuts

4. **Connect from the Flutter app** using the displayed IP address

5. **Control your presentation** from your phone!

## Keyboard Shortcuts Used

- **F5**: Start presentation
- **Esc**: End presentation  
- **Right Arrow**: Next slide
- **Left Arrow**: Previous slide

## Network Requirements

- Both your computer and phone must be on the **same WiFi network**
- Make sure your firewall allows connections on port 8080
- If you have issues, try temporarily disabling your firewall

## Troubleshooting

### Connection Issues
- Ensure both devices are on the same WiFi network
- Check if port 8080 is blocked by firewall
- Try restarting the server

### Presentation Not Responding
- Make sure the presentation software window is in focus
- Try clicking on the presentation window before using the remote
- Some software may require different keyboard shortcuts

### Permission Issues (macOS)
- Grant accessibility permissions to Terminal/Python in System Preferences > Security & Privacy > Privacy > Accessibility

## Supported Presentation Software

✅ **Tested and Working:**
- Microsoft PowerPoint
- Google Slides (Browser)
- LibreOffice Impress
- Apple Keynote
- PDF viewers (Adobe Reader, etc.)

## Custom Configuration

You can modify the keyboard shortcuts in the `SlideController` class:

```python
def next_slide(self):
    pyautogui.press('space')  # Change to space bar
    
def previous_slide(self):
    pyautogui.press('backspace')  # Change to backspace
```

## Security Note

This server only accepts connections from devices on your local network. It does not expose any system functionality beyond keyboard automation for presentations.
