# Physio Platform - Android Mobile App

A mobile Android application for remote physiotherapy sessions with AI-powered pose detection.

## Quick Start

```bash
# Install dependencies
cd frontend
npm install

# Build web app
npm run build

# Sync to Android
npm run android:sync

# Open in Android Studio
npm run android:open
```

## Features

- ✅ Real-time pose detection using MediaPipe
- ✅ Exercise form validation
- ✅ Therapist-patient video sessions
- ✅ Real-time feedback system
- ✅ Session reports and analytics
- ✅ Mobile-optimized UI
- ✅ Camera permissions handling
- ✅ Network status monitoring

## Requirements

- Node.js 16+
- Android Studio
- Java JDK 17+
- Android SDK (API 22+)

## Project Structure

```
frontend/          # React web application
android/           # Android native project (Capacitor)
backend/           # FastAPI backend server
```

## Building for Production

See [ANDROID_SETUP.md](./ANDROID_SETUP.md) for detailed instructions.

## License

MIT

