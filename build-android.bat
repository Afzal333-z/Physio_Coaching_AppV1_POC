@echo off
REM Build script for Android app (Windows)
REM Usage: build-android.bat [debug|release]

set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=debug

echo 🚀 Building Physio Platform Android App...
echo Build type: %BUILD_TYPE%

REM Navigate to frontend directory
cd /d "%~dp0frontend"

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    call npm install
)

REM Build web app
echo 🔨 Building web app...
call npm run build

REM Sync to Android
echo 🔄 Syncing to Android...
call npx cap sync android

REM Build Android app
cd ..\android

if "%BUILD_TYPE%"=="release" (
    echo 📱 Building release APK...
    call gradlew.bat assembleRelease
    echo ✅ Release APK built at: app\build\outputs\apk\release\app-release.apk
) else (
    echo 📱 Building debug APK...
    call gradlew.bat assembleDebug
    echo ✅ Debug APK built at: app\build\outputs\apk\debug\app-debug.apk
)

echo ✨ Build complete!
pause

