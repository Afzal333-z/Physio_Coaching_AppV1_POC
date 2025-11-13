#!/bin/bash

# Build script for Android app
# Usage: ./build-android.sh [debug|release]

set -e

BUILD_TYPE=${1:-debug}

echo "🚀 Building Physio Platform Android App..."
echo "Build type: $BUILD_TYPE"

# Navigate to frontend directory
cd "$(dirname "$0")/frontend"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build web app
echo "🔨 Building web app..."
npm run build

# Sync to Android
echo "🔄 Syncing to Android..."
npx cap sync android

# Build Android app
cd ../android

if [ "$BUILD_TYPE" = "release" ]; then
    echo "📱 Building release APK..."
    ./gradlew assembleRelease
    echo "✅ Release APK built at: app/build/outputs/apk/release/app-release.apk"
else
    echo "📱 Building debug APK..."
    ./gradlew assembleDebug
    echo "✅ Debug APK built at: app/build/outputs/apk/debug/app-debug.apk"
fi

echo "✨ Build complete!"

