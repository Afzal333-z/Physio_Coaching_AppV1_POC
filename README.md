# Physio Platform - Remote Physiotherapy Coaching App

A comprehensive platform for remote physiotherapy sessions with AI-powered pose detection and real-time exercise form validation.

## 🎯 Features

- **Real-time Pose Detection** - Uses MediaPipe AI for accurate body pose tracking
- **Exercise Form Validation** - Validates exercise form and provides accuracy scores
- **Therapist Dashboard** - Monitor multiple patients simultaneously
- **Patient View** - Real-time feedback and form correction guidance
- **WebRTC Video** - Real-time video communication between therapist and patients
- **Session Reports** - Generate detailed session reports with analytics
- **Mobile App** - Native Android app with full functionality

## 📱 Platforms

- **Web App** - React-based web application
- **Android App** - Native Android app built with Capacitor
- **Backend API** - FastAPI server for session management

## 🚀 Quick Start

### Prerequisites

- Node.js 16+ 
- Python 3.8+
- Android Studio (for Android app)
- Java JDK 17+ (for Android app)

### Web App Setup

```bash
cd frontend
npm install
npm run dev
```

### Backend Setup

```bash
cd backend
pip install -r requirements.txt
python main.py
```

### Android App Setup

See [QUICK_START.md](./QUICK_START.md) for detailed instructions.

```bash
cd frontend
npm install
npm run build
npm run android:sync
npm run android:open
```

## 📁 Project Structure

```
Physio_Coaching_AppV1_POC/
├── frontend/              # React web application
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── context/       # React context providers
│   │   ├── services/      # API and pose detection services
│   │   └── utils/         # Utility functions
│   └── package.json
├── backend/               # FastAPI backend
│   ├── main.py           # Main API server
│   └── requirements.txt
├── android/               # Android native project
│   └── app/              # Android app source
└── docs/                 # Documentation
```

## 🛠️ Technologies

### Frontend
- React 18
- Vite
- Tailwind CSS
- MediaPipe Pose Detection
- WebRTC
- Socket.io Client
- Capacitor (for mobile)

### Backend
- FastAPI
- WebSockets
- Python 3.8+

### Mobile
- Capacitor
- Android SDK
- Gradle

## 📚 Documentation

- [Quick Start Guide](./QUICK_START.md) - Get started quickly
- [Android Setup](./ANDROID_SETUP.md) - Detailed Android setup
- [Installation Guide](./INSTALL.md) - Complete installation steps
- [Mobile Conversion Summary](./MOBILE_CONVERSION_SUMMARY.md) - Mobile app details

## 🔧 Development

### Web Development

```bash
cd frontend
npm run dev          # Start dev server
npm run build        # Build for production
npm run preview      # Preview production build
```

### Backend Development

```bash
cd backend
python main.py       # Start development server
```

### Android Development

```bash
cd frontend
npm run android:sync # Sync web build to Android
npm run android:open # Open in Android Studio
npm run android:run  # Build and run on device
```

## 📦 Building for Production

### Web App

```bash
cd frontend
npm run build
```

Output: `frontend/dist/`

### Android APK

```bash
cd android
./gradlew assembleRelease
```

Output: `android/app/build/outputs/apk/release/app-release.apk`

### Android AAB (Google Play)

```bash
cd android
./gradlew bundleRelease
```

Output: `android/app/build/outputs/bundle/release/app-release.aab`

## 🔐 Environment Variables

Create `.env` file in `frontend/` directory:

```env
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000
```

For Android emulator:
```env
VITE_API_URL=http://10.0.2.2:8000
VITE_WS_URL=ws://10.0.2.2:8000
```

## 🧪 Testing

### Web App
Open browser and navigate to `http://localhost:5173`

### Backend API
API runs on `http://localhost:8000`
API docs: `http://localhost:8000/docs`

### Android App
Use Android Studio to run on emulator or physical device

## 📝 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please open an issue on GitHub.

## 🙏 Acknowledgments

- MediaPipe for pose detection
- Capacitor for mobile app framework
- FastAPI for backend framework

---

Made with ❤️ for remote physiotherapy

