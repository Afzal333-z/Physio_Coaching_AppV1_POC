# 🎥 Camera Testing Guide for Android Emulator

This guide explains how to test the Physio Coaching App with your laptop's camera in the Android Studio emulator.

## 📋 Table of Contents
- [Quick Start](#quick-start)
- [Session ID Testing Mode](#session-id-testing-mode)
- [Camera Setup Options](#camera-setup-options)
- [Option 1: Using React Web App (Recommended)](#option-1-using-react-web-app-recommended)
- [Option 2: Configure Emulator Camera](#option-2-configure-emulator-camera)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Prerequisites
- Android Studio with an Android Virtual Device (AVD)
- Working laptop camera
- Node.js and Python installed

### What's Enabled for Testing

✅ **Session ID Validation**: **ACCEPTS ANY CODE** - No backend required!
✅ **Camera Access**: Can use your laptop's webcam through emulator
✅ **Pose Detection**: Full MediaPipe pose tracking (React app)
✅ **No Backend Required**: Pure local testing mode

---

## 🔓 Session ID Testing Mode

### How It Works

The Flutter app is configured to accept **ANY session code** for testing purposes:

```dart
// lib/providers/session_provider.dart
// TESTING MODE: ACCEPTS ANY SESSION CODE WITHOUT VALIDATION
_sessionCode = code.toUpperCase().padRight(6, 'X').substring(0, 6);
```

### What This Means

| Action | Result |
|--------|--------|
| Enter `ABC123` | ✅ Joins successfully |
| Enter `TEST` | ✅ Joins successfully (auto-formatted to `TESTXX`) |
| Enter `123456` | ✅ Joins successfully |
| Enter ANY text | ✅ **Always succeeds** |

**Visual Indicator**: The join screen shows an orange "🧪 Testing Mode Active" banner to remind you that validation is disabled.

**No Backend Needed**: You don't need to run the FastAPI backend for patient join functionality.

---

## 📹 Camera Setup Options

There are **two main approaches** for testing with your laptop camera:

### Comparison Table

| Feature | React Web App | Native Flutter |
|---------|---------------|----------------|
| **Setup Difficulty** | ⭐ Easy | ⭐⭐⭐ Complex |
| **Camera Access** | ✅ Built-in | ❌ Requires implementation |
| **Pose Detection** | ✅ MediaPipe working | ❌ Not implemented |
| **Best For** | Testing full features | UI/UX testing only |

---

## ⭐ Option 1: Using React Web App (Recommended)

This is the **easiest and fastest** way to test the full camera + pose detection functionality.

### Step 1: Start the Backend Server

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

Backend should start on `http://localhost:8000`

### Step 2: Start the React Frontend

```bash
cd frontend
npm install
npm start
```

Frontend should start on `http://localhost:3000`

### Step 3: Configure Android Emulator for Localhost Access

The Android emulator can't access `localhost` directly. Use the special IP:

**For Backend**: `http://10.0.2.2:8000`
**For Frontend**: `http://10.0.2.2:3000`

### Step 4: Open Chrome in Emulator

1. Launch your Android emulator from Android Studio
2. Open the **Chrome browser** app on the emulator
3. Navigate to: `http://10.0.2.2:3000`

### Step 5: Test the Camera

1. Select **"Patient"** role
2. Enter **any session code** (e.g., `TEST123`)
3. Enter your name
4. Click **"Join Session"**
5. When prompted, **allow camera permissions**
6. Your laptop camera feed should appear with pose detection skeleton overlay!

### What You'll See

✅ Live camera feed from your laptop
✅ Real-time pose detection skeleton
✅ Accuracy percentage
✅ Joint angle calculations
✅ Exercise feedback

---

## 🔧 Option 2: Configure Emulator Camera

If you want to test camera access in native apps (Chrome permission flows, etc.), configure the AVD:

### Step 1: Open AVD Manager

In Android Studio:
1. Click **Tools** → **Device Manager**
2. Find your emulator
3. Click the **✏️ Edit** icon

### Step 2: Configure Camera Settings

In the AVD configuration:

1. Scroll to **Camera** section
2. Set **Front camera**: `Webcam0` (or your laptop's camera name)
3. Set **Back camera**: `Webcam0` or `VirtualScene`
4. Click **Finish**

### Step 3: Verify Camera in Emulator

1. Start the emulator
2. Open the **Camera** app (pre-installed)
3. Switch to front camera
4. You should see your laptop's camera feed!

### Step 4: Test in Browser

1. Open Chrome in the emulator
2. Navigate to a camera test site: `https://webcamtests.com`
3. Allow camera permissions
4. Your laptop camera should work

### AVD Camera Options

| Setting | Description | Recommended |
|---------|-------------|-------------|
| `Webcam0` | Your laptop's camera | ✅ Yes (for front) |
| `VirtualScene` | 3D scene (not real camera) | For back camera |
| `Emulated` | Software-rendered camera | Not recommended |
| `None` | Disables camera | Not useful |

---

## 🧪 Complete Testing Workflow

### Full Feature Test (React Web App)

```bash
# Terminal 1: Backend
cd backend
source venv/bin/activate
python main.py

# Terminal 2: Frontend
cd frontend
npm start

# Emulator: Chrome Browser
# Navigate to: http://10.0.2.2:3000
# Join as patient with ANY code
# Test camera and pose detection
```

### UI/UX Test Only (Flutter App)

```bash
# Terminal: Run Flutter app
flutter run

# In the app:
# - Join session with ANY code (e.g., "TEST")
# - Explore UI layouts
# - Test navigation
# Note: Camera won't work (placeholder only)
```

---

## 🐛 Troubleshooting

### Camera Not Working in Emulator

**Problem**: Camera permissions denied or black screen

**Solutions**:
1. **Reset app permissions**:
   - Settings → Apps → Chrome → Permissions → Camera → Allow
2. **Restart emulator** after changing AVD camera settings
3. **Check laptop camera** is not being used by another app
4. **Try different camera**: Some laptops have multiple cameras (front/IR)

```bash
# List available cameras on Linux
ls -l /dev/video*

# On macOS, cameras are managed by System Preferences
```

### Camera Works but Not in Chrome

**Problem**: Browser can't access camera even with permissions

**Solutions**:
1. **Use HTTPS** (Chrome may block camera on HTTP):
   ```bash
   # Option 1: Use ngrok for HTTPS tunnel
   npx ngrok http 3000

   # Option 2: Enable Chrome flag
   chrome://flags/#unsafely-treat-insecure-origin-as-secure
   ```
2. **Clear Chrome data** in emulator settings
3. **Use a different browser** (Firefox, Edge) if available

### Backend Connection Issues

**Problem**: `ERR_CONNECTION_REFUSED` when accessing `10.0.2.2:8000`

**Solutions**:
1. **Verify backend is running**:
   ```bash
   curl http://localhost:8000/api/health
   ```
2. **Check firewall** isn't blocking port 8000
3. **Use the correct special IP**:
   - `10.0.2.2` = Host machine (your laptop)
   - `localhost` = The emulator itself ❌
   - `127.0.0.1` = The emulator itself ❌

### Session Code Not Working

**Problem**: "Session not found" error

**This shouldn't happen in testing mode!** If you see this:

1. **Check for testing banner** - orange "🧪 Testing Mode Active" should appear
2. **Verify code changes**:
   ```dart
   // lib/providers/session_provider.dart line 111-129
   // Should have testing mode comments
   ```
3. **Hot reload Flutter app**: Press `r` in terminal
4. **If still broken**: The testing mode was accidentally removed

### Pose Detection Not Showing

**Problem**: Camera works but no skeleton overlay

**Causes**:
1. Using Flutter app (pose detection not implemented) → Use React web app
2. MediaPipe not loading → Check browser console for errors
3. Poor lighting → MediaPipe needs good visibility

**Solutions**:
```javascript
// Check in browser console (F12)
// Should see: "MediaPipe Pose loaded successfully"

// If not, verify frontend/src/services/poseDetection.js loaded:
console.log(window.Pose); // Should be defined
```

### Emulator Performance Issues

**Problem**: Lag, freezing, or slow camera

**Solutions**:
1. **Allocate more RAM** to AVD (4GB+ recommended)
2. **Enable hardware acceleration**:
   - AVD settings → Graphics: `Hardware - GLES 2.0`
3. **Close other apps** to free CPU/GPU resources
4. **Lower camera resolution** in code:
   ```javascript
   // frontend/src/components/PatientView.jsx
   const constraints = {
     video: {
       width: { ideal: 320 },  // Lower from 640
       height: { ideal: 240 }, // Lower from 480
       facingMode: 'user'
     }
   };
   ```

### WebSocket Connection Failing

**Problem**: Real-time updates not working

**Note**: In testing mode, WebSocket is **disabled by default** (see line 124-125 in `session_provider.dart`)

**If you need WebSocket for testing**:
1. Uncomment: `_webSocketService.connect(_sessionCode, _userId);`
2. Start backend server
3. Update WebSocket URL to use `ws://10.0.2.2:8000`

---

## 📝 Testing Checklist

### Basic Functionality
- [ ] Flutter app builds and runs on emulator
- [ ] Can join session with ANY code (e.g., "TEST", "ABC123")
- [ ] Testing mode banner appears on join screen
- [ ] Navigation works (back buttons, screen transitions)

### Camera Testing (React Web App)
- [ ] Backend starts without errors
- [ ] Frontend starts and loads at `http://10.0.2.2:3000`
- [ ] Camera permission prompt appears in Chrome
- [ ] Laptop camera feed displays in browser
- [ ] Pose detection skeleton overlay appears
- [ ] Accuracy percentage updates in real-time
- [ ] Exercise information displays correctly

### Performance Testing
- [ ] Camera feed is smooth (30 FPS)
- [ ] Pose detection updates without lag
- [ ] No app crashes when enabling/disabling camera
- [ ] Memory usage stays reasonable (<500MB)

---

## 🎯 Quick Reference

### Key Files Modified for Testing

| File | Change | Line |
|------|--------|------|
| `lib/providers/session_provider.dart` | Accept any session code | 110-130 |
| `lib/screens/join_session_screen.dart` | Testing mode banner | 369-424 |

### Important URLs

| Service | Localhost (Your PC) | Emulator Access |
|---------|---------------------|-----------------|
| Backend API | `http://localhost:8000` | `http://10.0.2.2:8000` |
| Frontend Web | `http://localhost:3000` | `http://10.0.2.2:3000` |
| WebSocket | `ws://localhost:8000/ws/` | `ws://10.0.2.2:8000/ws/` |

### Test Commands

```bash
# Check backend health
curl http://localhost:8000/api/health

# Check if frontend is accessible
curl http://localhost:3000

# Test camera in terminal (Linux)
ffplay /dev/video0

# Run Flutter with verbose logging
flutter run -v

# View Flutter logs
flutter logs

# Hot reload Flutter app
# Press 'r' in the terminal running flutter run
```

---

## 🎉 Success Indicators

When everything is working, you should see:

### In Flutter App
✅ Orange testing mode banner
✅ Accepts any session code
✅ Navigates to patient view screen
✅ UI renders without errors

### In React Web App (Emulator Chrome)
✅ Camera permission granted
✅ Live video feed from laptop camera
✅ Green skeleton overlay tracking your movement
✅ Accuracy percentage (0-100%) updating
✅ Joint angles displaying in real-time
✅ Exercise name and instructions visible

---

## 📞 Need Help?

If you encounter issues not covered here:

1. **Check browser console** (F12 in Chrome)
2. **Check backend logs** (terminal running `python main.py`)
3. **Check Flutter logs** (`flutter logs`)
4. **Verify file changes** weren't accidentally reverted

**Known Limitations**:
- Flutter app shows camera placeholder only (no actual camera)
- For full testing, use React web app in emulator's Chrome
- Pose detection only works in React app (MediaPipe)
- Testing mode bypasses all backend validation

---

**Last Updated**: 2025-11-13
**Testing Mode**: ✅ Enabled
**Backend Required**: ❌ No (for session join)
**Camera Support**: ✅ Yes (via React web app)
