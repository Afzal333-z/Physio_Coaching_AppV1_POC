# 📱 Mobile Camera Testing Guide - Flutter App

## ✅ What's Been Implemented

The Flutter mobile app now has **REAL camera functionality**:

- ✅ Camera initialization with permission handling
- ✅ Front camera selection (for selfie view)
- ✅ Camera preview display
- ✅ Toggle camera on/off
- ✅ Error handling and retry logic
- ✅ Visual camera status indicator

---

## 🚀 How to Test on Android Emulator

### Step 1: Configure Emulator Camera

1. **Open AVD Manager** in Android Studio
   - Click **Tools** → **Device Manager**

2. **Edit your emulator**
   - Click the **✏️ (Edit)** icon next to your emulator

3. **Set Camera to use your laptop webcam**
   - Scroll to **Camera** section
   - **Front camera**: Select **Webcam0** (your laptop camera)
   - **Back camera**: Select **Webcam0** or **VirtualScene**
   - Click **Finish**

4. **Restart the emulator** if it's already running

### Step 2: Verify Emulator Camera Works

Before testing the app, verify the emulator can see your camera:

1. Open the **Camera** app on the emulator (pre-installed)
2. Switch to front camera
3. You should see your laptop's webcam feed
4. If you see yourself - ✅ Camera is configured correctly!

### Step 3: Run the Flutter App

```bash
flutter run
```

Or press **Run** in Android Studio.

### Step 4: Test Camera in the App

1. **Join a session**
   - Select "Patient" role
   - Enter ANY code (e.g., "TEST")
   - Enter your name
   - Click "Join Session"

2. **Camera should auto-start**
   - You'll see: "Camera Active • 2 camera(s) found" (green badge)
   - Your laptop camera feed should appear in the preview box
   - You should see yourself!

3. **Toggle camera on/off**
   - Click "Turn Off Camera" button
   - Camera feed stops, shows camera-off icon
   - Click "Turn On Camera"
   - Camera restarts

---

## 🔍 What to Look For

### ✅ Success Indicators

| What to Check | Expected Result |
|---------------|-----------------|
| **Permission Dialog** | Shows once on first launch |
| **Camera Status Badge** | Green "Camera Active • X camera(s) found" |
| **Camera Preview** | Live feed from laptop webcam |
| **Toggle Button** | Turns camera on/off smoothly |
| **Error Handling** | Graceful error messages if camera fails |

### 📊 Camera Status Meanings

| Badge Color | Icon | Message | Meaning |
|-------------|------|---------|---------|
| 🟢 Green | `videocam` | "Camera Active • 2 camera(s) found" | ✅ Working perfectly |
| 🟠 Orange | `videocam_off` | "Camera Off" | Camera disabled by user |
| 🟠 Orange | `videocam_off` | "Camera Initializing..." | Starting up |
| 🔴 Red | `error` | "Camera Error: ..." | Something went wrong |

---

## 🐛 Troubleshooting

### Problem: "No cameras found on this device"

**Cause**: Emulator can't detect laptop camera

**Solutions**:
1. **Check AVD camera settings**:
   - AVD Manager → Edit → Camera section
   - Set Front camera to **Webcam0**
2. **Restart emulator** after changing settings
3. **Check laptop camera is not in use** by another app
4. **Try different camera**:
   - Some laptops have multiple cameras (webcam, IR camera)
   - Try **Webcam1** or **Webcam2** in AVD settings

### Problem: "Camera permission denied"

**Cause**: User denied camera permission

**Solutions**:
1. **Click "Open Settings"** button in the app
2. Manually grant camera permission
3. Or **reset app**:
   ```bash
   flutter clean
   flutter run
   ```
4. When permission dialog appears, click **Allow**

### Problem: Black screen in camera preview

**Cause**: Camera initialized but no feed

**Solutions**:
1. **Check laptop camera** works in other apps (Photo Booth, Zoom, etc.)
2. **Close other apps** using the camera
3. **Restart emulator**
4. **Check camera LED** - should be lit when camera is active
5. **Try back camera**:
   ```dart
   // In patient_view_screen.dart line 49
   // Change from:
   final camera = _cameras!.length > 1 ? _cameras![1] : _cameras![0];
   // To:
   final camera = _cameras![0]; // Use first available camera
   ```

### Problem: "Camera initialization failed: CameraException"

**Cause**: Camera plugin error

**Solutions**:
1. **Run flutter clean**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
2. **Check camera package version** in `pubspec.yaml`:
   ```yaml
   camera: ^0.10.5+5
   ```
3. **Clear app data** on emulator:
   - Settings → Apps → Physio Platform → Storage → Clear Data

### Problem: App crashes when opening camera

**Cause**: Missing permissions or plugin issue

**Solutions**:
1. **Verify AndroidManifest.xml** has camera permission (line 3):
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   ```
2. **Rebuild app**:
   ```bash
   flutter clean
   flutter run
   ```
3. **Check console logs** for error details:
   ```bash
   flutter logs
   ```

### Problem: Camera is slow/laggy

**Cause**: Emulator performance

**Solutions**:
1. **Lower camera resolution** in code (line 54):
   ```dart
   // Change from ResolutionPreset.medium to:
   ResolutionPreset.low,
   ```
2. **Allocate more RAM** to emulator:
   - AVD Manager → Edit → Advanced Settings
   - RAM: 4GB or more
3. **Enable hardware acceleration**:
   - AVD → Graphics: **Hardware - GLES 2.0**

---

## 📱 Testing on Real Android Device

Want to test on a real phone instead of emulator?

### Step 1: Enable Developer Mode

1. **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. Go back → **Developer Options**
4. Enable **USB Debugging**

### Step 2: Connect Device

```bash
# Check device is connected
adb devices

# You should see your device listed
# Example:
# List of devices attached
# ABC123XYZ    device
```

### Step 3: Run on Device

```bash
flutter run
```

Flutter will detect your phone and install the app.

### Advantages of Real Device Testing

| Feature | Emulator | Real Device |
|---------|----------|-------------|
| Camera Quality | Limited | ✅ Native camera |
| Performance | Slow | ✅ Fast |
| Real-world Testing | ❌ | ✅ Accurate |
| Pose Detection | Lag | ✅ Smooth |

---

## 🎯 Camera Code Explanation

### Key Files Modified

**lib/screens/patient_view_screen.dart**

```dart
// Camera initialization (line 28-78)
Future<void> _initializeCamera() async {
  // 1. Request permission
  final status = await Permission.camera.request();

  // 2. Get available cameras
  _cameras = await availableCameras();

  // 3. Select front camera (index 1)
  final camera = _cameras![1];

  // 4. Initialize controller
  _cameraController = CameraController(
    camera,
    ResolutionPreset.medium,
    enableAudio: false,
  );

  // 5. Start camera
  await _cameraController!.initialize();
}

// Camera preview widget (line 129-136)
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: AspectRatio(
    aspectRatio: _cameraController!.value.aspectRatio,
    child: CameraPreview(_cameraController!),
  ),
)
```

### Camera Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| **Resolution** | `ResolutionPreset.medium` | Balance quality/performance |
| **Audio** | `false` | No audio recording needed |
| **Image Format** | `ImageFormatGroup.jpeg` | Standard format |
| **Camera Selection** | Index 1 (front) | For selfie view |

---

## 📊 Testing Checklist

### Basic Camera Tests
- [ ] App requests camera permission on first launch
- [ ] Camera permission dialog appears
- [ ] Clicking "Allow" grants permission
- [ ] Camera status shows "Camera Active" (green)
- [ ] Camera preview displays laptop webcam feed
- [ ] You can see yourself in the preview

### Toggle Tests
- [ ] "Turn Off Camera" button stops camera
- [ ] Camera preview shows camera-off icon
- [ ] Status badge shows "Camera Off" (orange)
- [ ] "Turn On Camera" button restarts camera
- [ ] Camera feed resumes smoothly

### Error Handling Tests
- [ ] If permission denied, shows error message
- [ ] "Open Settings" button works
- [ ] If camera unavailable, shows error
- [ ] "Retry" button re-initializes camera
- [ ] App doesn't crash on camera errors

### Performance Tests
- [ ] Camera starts within 2-3 seconds
- [ ] Preview is smooth (30 FPS)
- [ ] No memory leaks (check with DevTools)
- [ ] Camera stops when leaving screen
- [ ] App remains responsive with camera on

---

## 🔬 Advanced: Adding Pose Detection

The camera is now working! Want to add pose detection to the mobile app?

### Option 1: TensorFlow Lite (Native)

```dart
// Add to pubspec.yaml
dependencies:
  tflite: ^1.1.2

// Download MoveNet or PoseNet model
// Process camera frames for pose landmarks
```

**Pros**: Native performance, works offline
**Cons**: Model integration complexity

### Option 2: ML Kit Pose Detection (Google)

```dart
// Add to pubspec.yaml
dependencies:
  google_mlkit_pose_detection: ^0.10.0

// Use Google's ML Kit for pose tracking
```

**Pros**: Easy to integrate, accurate
**Cons**: Requires Google Play Services

### Option 3: Web View with MediaPipe

Use the existing React web app in a WebView:

```dart
// Embed the React app (which already has pose detection)
// Camera works through web getUserMedia API
```

**Pros**: Reuse existing code, no model porting
**Cons**: Performance overhead

**Would you like me to implement pose detection? Let me know which option you prefer!**

---

## 📝 Quick Reference Commands

```bash
# Run app on emulator
flutter run

# Run with verbose logging
flutter run -v

# Check camera plugin installation
flutter doctor -v

# Clear cache and rebuild
flutter clean && flutter pub get && flutter run

# View real-time logs
flutter logs

# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Build APK for testing
flutter build apk --debug

# Install APK on device
flutter install
```

---

## ✅ Summary

**Current Status**:
- ✅ Real camera working in Flutter app
- ✅ Permission handling implemented
- ✅ Front camera (selfie mode)
- ✅ Toggle on/off functionality
- ✅ Error handling with retry
- ✅ Visual status indicators
- ❌ Pose detection (not yet implemented)

**To Test**:
1. Configure emulator camera to Webcam0
2. Run `flutter run`
3. Join with code "TEST"
4. Camera should show your laptop webcam feed

**Next Steps**:
- Add pose detection (TensorFlow Lite or ML Kit)
- Add skeleton overlay
- Calculate joint angles
- Send pose data to backend

---

**Questions or Issues?**

Check the logs:
```bash
flutter logs | grep -i camera
```

The camera implementation is in:
- `lib/screens/patient_view_screen.dart` (lines 1-380)

---

**Last Updated**: 2025-11-13
**Camera Status**: ✅ Fully Implemented
**Pose Detection**: ❌ Not Yet Implemented
