# Physio Platform - Flutter Android App

A native Android mobile application built with Flutter for remote physiotherapy sessions with AI-powered pose detection and real-time exercise form validation.

## 📱 Features

- **Real-time Pose Detection** - Uses MediaPipe AI for accurate body pose tracking
- **Exercise Form Validation** - Validates exercise form and provides accuracy scores
- **Therapist Dashboard** - Monitor multiple patients simultaneously
- **Patient View** - Real-time feedback and form correction guidance
- **Session Reports** - Generate detailed session reports with analytics
- **Native Flutter App** - Built with Flutter for native performance

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio (latest version)
- Java JDK 17+
- Android SDK (API 21+)

### Installation

1. **Install Flutter:**
   ```bash
   # Download Flutter from https://flutter.dev/docs/get-started/install
   # Add Flutter to your PATH
   flutter doctor
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
Physio_Coaching_AppV1_POC/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   ├── screens/                  # UI screens
│   ├── services/                 # API and WebSocket services
│   └── utils/                    # Utility functions
├── android/                      # Android native configuration
└── pubspec.yaml                  # Flutter dependencies
```

## 🛠️ Build Commands

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK
flutter build apk

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

## 🔧 Configuration

### Backend URL

Update the API URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:8000';
```

For Android emulator, use: `http://10.0.2.2:8000`
For physical device, use your computer's IP address.

### App Configuration

Edit `android/app/build.gradle` to customize:
- Application ID
- Version code/name
- Signing configuration

## 📚 Dependencies

- `provider` - State management
- `http` - HTTP client for API calls
- `web_socket_channel` - WebSocket support
- `camera` - Camera access
- `permission_handler` - Permission management

## 🔐 Permissions

The app requires:
- **Camera** - For pose detection
- **Internet** - For API calls
- **Network State** - To check connectivity

## 🧪 Testing

1. Start the backend server:
   ```bash
   cd backend
   python main.py
   ```

2. Run the Flutter app:
   ```bash
   flutter run
   ```

## 📝 License

MIT License

## 🙏 Acknowledgments

- MediaPipe for pose detection
- Flutter for cross-platform framework
- FastAPI for backend framework

---

Made with ❤️ for remote physiotherapy
