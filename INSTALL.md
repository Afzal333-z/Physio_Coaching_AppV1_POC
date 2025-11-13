# Installation Guide

## Complete Setup Instructions

### Step 1: Install Node.js Dependencies

```bash
cd Physio_Coaching_AppV1_POC/frontend
npm install
```

This will install:
- React and React DOM
- Capacitor and all plugins
- Build tools (Vite, Tailwind CSS, etc.)

### Step 2: Configure Environment Variables

Create a `.env` file in the `frontend/` directory:

**For Android Emulator:**
```env
VITE_API_URL=http://10.0.2.2:8000
VITE_WS_URL=ws://10.0.2.2:8000
```

**For Physical Android Device:**
```env
VITE_API_URL=http://YOUR_COMPUTER_IP:8000
VITE_WS_URL=ws://YOUR_COMPUTER_IP:8000
```

To find your computer's IP:
- Windows: `ipconfig` (look for IPv4 Address)
- Mac/Linux: `ifconfig` or `ip addr`

### Step 3: Build the Web App

```bash
npm run build
```

This creates the `dist/` folder with optimized production build.

### Step 4: Initialize Capacitor (First Time Only)

```bash
npx cap add android
```

This creates the `android/` directory with native Android project.

### Step 5: Sync to Android

```bash
npm run android:sync
```

This copies the built web app to the Android project.

### Step 6: Open in Android Studio

```bash
npm run android:open
```

Or manually:
```bash
npx cap open android
```

### Step 7: Setup Android Studio

1. Wait for Gradle sync to complete
2. If prompted, install missing SDK components
3. Create an Android Virtual Device (AVD) if testing on emulator:
   - Tools → Device Manager → Create Device
   - Select a device (e.g., Pixel 5)
   - Select a system image (API 30+ recommended)
   - Finish setup

### Step 8: Run the App

**Option A: Using Android Studio**
- Click the green "Run" button
- Select your device/emulator
- Wait for app to install and launch

**Option B: Using Command Line**
```bash
npm run android:run
```

## Verifying Installation

1. App should launch on device/emulator
2. You should see the landing page with "I'm a Therapist" and "I'm a Patient" options
3. Camera permission should be requested when starting a session

## Common Issues

### Issue: "npm: command not found"
**Solution:** Install Node.js from https://nodejs.org/

### Issue: "Gradle sync failed"
**Solution:** 
- Ensure Java JDK 17+ is installed
- In Android Studio: File → Invalidate Caches / Restart

### Issue: "Camera not working"
**Solution:**
- Check app permissions: Settings → Apps → Physio Platform → Permissions
- Ensure Camera permission is granted

### Issue: "Cannot connect to backend"
**Solution:**
- Ensure backend is running: `cd backend && python main.py`
- Check `.env` file has correct IP address
- For emulator, use `10.0.2.2` instead of `localhost`
- Check firewall settings

### Issue: "Build failed"
**Solution:**
```bash
cd android
./gradlew clean
cd ..
npm run build
npm run android:sync
```

## Development Workflow

1. Make changes to React code in `frontend/src/`
2. Test in browser: `npm run dev`
3. Build: `npm run build`
4. Sync: `npm run android:sync`
5. Test in Android Studio or on device

## Building Release Version

See `ANDROID_SETUP.md` for detailed instructions on building release APK/AAB for distribution.

## Need Help?

- Quick Start: See `QUICK_START.md`
- Detailed Guide: See `ANDROID_SETUP.md`
- Summary: See `MOBILE_CONVERSION_SUMMARY.md`

