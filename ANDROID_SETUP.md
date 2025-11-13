# Android App Setup Guide

This guide will help you build and run the Physio Platform Android app.

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
cd Physio_Coaching_AppV1_POC/frontend
npm install
```

### 2. Build the Web App

Build the React app for production:

```bash
npm run build
```

### 3. Initialize Capacitor (if not already done)

```bash
npx cap add android
```

### 4. Sync Capacitor

Sync the web build with the Android project:

```bash
npm run android:sync
```

Or manually:

```bash
npx cap sync android
```

### 5. Open in Android Studio

```bash
npm run android:open
```

Or manually:

```bash
npx cap open android
```

### 6. Build and Run

#### Option A: Using Android Studio
1. Open the project in Android Studio
2. Wait for Gradle sync to complete
3. Connect an Android device or start an emulator
4. Click "Run" button or press `Shift+F10`

#### Option B: Using Command Line

```bash
# Build and sync
npm run android:build

# Run on connected device
npm run android:run
```

Or using Gradle directly:

```bash
cd android
./gradlew assembleDebug
./gradlew installDebug
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

Update the API URL in `src/context/SessionContext.jsx`:

```javascript
const API_URL = import.meta.env.VITE_API_URL || 'http://your-backend-url:8000';
const WS_URL = import.meta.env.VITE_WS_URL || 'ws://your-backend-url:8000';
```

Or create a `.env` file:

```env
VITE_API_URL=http://your-backend-url:8000
VITE_WS_URL=ws://your-backend-url:8000
```

### App Configuration

Edit `capacitor.config.ts` to customize:
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
2. Test in browser: `npm run dev`
3. Build: `npm run build`
4. Sync: `npm run android:sync`
5. Test in Android Studio or on device

## Project Structure

```
Physio_Coaching_AppV1_POC/
├── frontend/              # React web app
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
# Development
npm run dev                    # Start dev server
npm run build                  # Build web app
npm run preview                # Preview built app

# Android
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

