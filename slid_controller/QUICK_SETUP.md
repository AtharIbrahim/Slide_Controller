# 🚀 QUICK SETUP GUIDE

## Step 1: Setup Python Server (Computer)

### Option A: Using Windows Batch Files (Easiest)
1. **Navigate to** `python_server` folder
2. **Double-click** `install.bat` to install dependencies
3. **Double-click** `start_server.bat` to start the server
4. **Note the IP address** shown in the console

### Option B: Using Command Line
```bash
cd python_server
pip install -r requirements.txt
python slide_controller_server.py
```

### Verify Setup (Optional)
```bash
python test_environment.py
```

## Step 2: Setup Flutter App (Phone)

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on your phone/emulator**:
   ```bash
   flutter run
   ```

## Step 3: Connect & Use

1. **Enter IP address** from Step 1 in the app
2. **Tap "Connect"**
3. **Open your presentation** on computer
4. **Tap "Start"** in the app
5. **Swipe left/right** to control slides!

---

## 🔥 Pro Tips

- **Keep both devices on the same WiFi**
- **Make sure presentation window is in focus**
- **Use F5 to start slideshow mode in most presentation software**
- **Test connection with a simple PowerPoint or PDF first**

## 🎯 Supported Software

✅ PowerPoint ✅ Google Slides ✅ PDF Viewers ✅ Keynote ✅ LibreOffice

---

**That's it! You're ready to present wirelessly!** 📱➡️💻
