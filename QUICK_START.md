# Quick Start Guide - Android App

## Prerequisites Check

- [ ] Node.js installed (v16+)
- [ ] Android Studio installed
- [ ] Java JDK 17+ installed
- [ ] Android SDK installed (API 22+)

## Step-by-Step Setup

### 1. Install Dependencies

```bash
cd Physio_Coaching_AppV1_POC/frontend
npm install
```

### 2. Configure Backend URL

Create `.env` file in `frontend/` directory:

```env
VITE_API_URL=http://your-backend-ip:8000
VITE_WS_URL=ws://your-backend-ip:8000
```

**For Android Emulator:**
```env
VITE_API_URL=http://10.0.2.2:8000
VITE_WS_URL=ws://10.0.2.2:8000
```

**For Physical Device:**
- Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Use that IP in the URLs

### 3. Build Web App

```bash
npm run build
```

### 4. Initialize Capacitor (First Time Only)

```bash
npx cap add android
```

### 5. Sync to Android

```bash
npm run android:sync
```

### 6. Open in Android Studio

```bash
npm run android:open
```

### 7. Run on Device/Emulator

- In Android Studio, click the "Run" button (green play icon)
- Or use: `npm run android:run`

## Quick Commands Reference

```bash
# Build and sync
npm run android:build

# Open Android Studio
npm run android:open

# Sync only (after code changes)
npm run android:sync

# Run on device
npm run android:run
```

## Troubleshooting

**"Gradle sync failed"**
- Check Java version: `java -version` (should be 17+)
- In Android Studio: File → Invalidate Caches / Restart

**"Camera not working"**
- Check app permissions in device Settings
- Ensure camera permission is granted

**"Cannot connect to backend"**
- Check backend is running: `cd backend && python main.py`
- Verify IP address in `.env` file
- For emulator, use `10.0.2.2` instead of `localhost`

**"Build failed"**
- Clean build: `cd android && ./gradlew clean`
- Rebuild: `npm run android:build`

## Next Steps

- See [ANDROID_SETUP.md](./ANDROID_SETUP.md) for detailed documentation
- See [README_ANDROID.md](./README_ANDROID.md) for feature overview

