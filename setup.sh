#!/bin/bash

# StudentNotifier - Quick Start Script
# This script helps you get the app running quickly

echo "🎓 StudentNotifier - Quick Start"
echo "================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter detected"
flutter --version
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Check for errors
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Dependencies installed successfully!"
    echo ""
    echo "🚀 Ready to run! Choose an option:"
    echo ""
    echo "1. Run on connected device:"
    echo "   flutter run"
    echo ""
    echo "2. Run on specific device:"
    echo "   flutter devices  (to list devices)"
    echo "   flutter run -d <device-id>"
    echo ""
    echo "3. Build APK:"
    echo "   flutter build apk"
    echo ""
    echo "4. Build for iOS:"
    echo "   flutter build ios"
    echo ""
    echo "📱 To launch the app now, run:"
    echo "   flutter run"
else
    echo ""
    echo "❌ Error installing dependencies"
    echo "Please check the error messages above"
    exit 1
fi
