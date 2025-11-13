# Android App Setup Guide

Complete guide for building and running the Physio Platform Android mobile app.

## Prerequisites

1. **Node.js** (v16 or higher)
2. **Android Studio** (latest version)
3. **Java JDK** (17 or higher)
4. **Android SDK** (API level 22+)
5. **Gradle** (will be downloaded automatically)

## Installation Steps

### 1. Install Dependencies

Navigate to the frontend directory and install all dependencies:

```bash
cd frontend
npm install
```

### 2. Build the App

Build the React app for production (this creates the files Android needs):

```bash
npm run build
```

### 3. Sync to Android

Sync the built app with the Android project:

```bash
npm run android:sync
```

Or manually:

```bash
npx cap sync android
```

### 4. Open in Android Studio

```bash
npm run android:open
```

Or manually:

```bash
npx cap open android
```

### 5. Setup Android Studio

1. Wait for Gradle sync to complete
2. If prompted, install missing SDK components
3. Create an Android Virtual Device (AVD) if testing on emulator:
   - Tools → Device Manager → Create Device
   - Select a device (e.g., Pixel 5)
   - Select a system image (API 30+ recommended)
   - Finish setup

### 6. Run the App

**Option A: Using Android Studio**
1. Click the green "Run" button
2. Select your device/emulator
3. Wait for app to install and launch

**Option B: Using Command Line**

```bash
npm run android:run
```

## Building Release APK/AAB

### 1. Generate a Keystore

```bash
keytool -genkey -v -keystore physio-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias physio-key
```

### 2. Update `android/app/build.gradle`

Add signing configuration:

```gradle
android {
    ...
    signingConfigs {
        release {
            storeFile file('path/to/physio-release-key.jks')
            storePassword 'your-store-password'
            keyAlias 'physio-key'
            keyPassword 'your-key-password'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Build Release APK

```bash
cd android
./gradlew assembleRelease
```

The APK will be at: `android/app/build/outputs/apk/release/app-release.apk`

### 4. Build Release AAB (for Google Play Store)

```bash
cd android
./gradlew bundleRelease
```

The AAB will be at: `android/app/build/outputs/bundle/release/app-release.aab`

## Configuration

### API URL Configuration

Update the API URL in `frontend/src/context/SessionContext.jsx`:

```javascript
const API_URL = import.meta.env.VITE_API_URL || 'http://your-backend-url:8000';
const WS_URL = import.meta.env.VITE_WS_URL || 'ws://your-backend-url:8000';
```

Or create a `.env` file in `frontend/`:

```env
VITE_API_URL=http://your-backend-url:8000
VITE_WS_URL=ws://your-backend-url:8000
```

### App Configuration

Edit `frontend/capacitor.config.ts` to customize:
- App ID (`appId`)
- App Name (`appName`)
- Splash screen settings
- Status bar settings
- Permissions

## Permissions

The app requires the following permissions:
- **Camera**: For pose detection and video streaming
- **Internet**: For API calls and WebSocket connections
- **Network State**: To check connectivity
- **Storage**: To save session reports

These are already configured in `AndroidManifest.xml`.

## Troubleshooting

### Gradle Sync Failed
- Ensure you have Java JDK 17 installed
- Check `android/gradle/wrapper/gradle-wrapper.properties` for correct Gradle version
- Try: `cd android && ./gradlew clean`

### Build Errors
- Clean build: `cd android && ./gradlew clean`
- Invalidate caches in Android Studio: File → Invalidate Caches / Restart

### Camera Not Working
- Check device permissions in Settings → Apps → Physio Platform → Permissions
- Ensure camera permission is granted

### Network Errors
- Check `network_security_config.xml` for allowed domains
- For localhost testing, use `10.0.2.2` (Android emulator) or your computer's IP address

### Capacitor Sync Issues
- Delete `android` folder and run `npx cap add android` again
- Ensure `npm run build` completed successfully before syncing

## Development Workflow

1. Make changes to React code in `frontend/src/`
2. Build: `npm run build`
3. Sync: `npm run android:sync`
4. Test in Android Studio or on device

## Project Structure

```
Physio_Coaching_AppV1_POC/
├── frontend/              # React source code
│   ├── src/              # Source code
│   ├── dist/             # Built web app (generated)
│   └── capacitor.config.ts
├── android/              # Android native project
│   ├── app/
│   │   └── src/main/
│   │       ├── java/     # Java source code
│   │       └── res/      # Android resources
│   └── build.gradle
└── backend/              # FastAPI backend
```

## Useful Commands

```bash
# Build
npm run build                  # Build web app
npm run android:sync          # Sync web build to Android
npm run android:open          # Open in Android Studio
npm run android:build         # Build and sync
npm run android:run           # Build, sync, and run

# Capacitor CLI
npx cap sync android          # Sync changes
npx cap open android          # Open in Android Studio
npx cap run android           # Run on device
npx cap copy android          # Copy web assets only
```

## Testing on Real Device

1. Enable Developer Options on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging

3. Connect device via USB

4. Run: `npm run android:run` or use Android Studio

## Publishing to Google Play Store

1. Build release AAB: `./gradlew bundleRelease`
2. Create a Google Play Console account
3. Create a new app listing
4. Upload the AAB file
5. Fill in store listing details
6. Submit for review

## Support

For issues or questions:
- Check Capacitor documentation: https://capacitorjs.com/docs
- Check Android Studio logs
- Check device logs: `adb logcat`
