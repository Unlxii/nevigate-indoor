#!/bin/bash

# Indoor Navigation - Run App Script
# สคริปต์สำหรับรันแอพบน emulator

echo "🎯 Indoor Navigation - Starting App..."
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please run: ./setup.sh first"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

echo ""

# Check for available devices
echo "📱 Checking for available devices..."
flutter devices

echo ""

# Check for running emulators
DEVICES=$(flutter devices | grep -c "emulator\|simulator\|device")

if [ "$DEVICES" -eq 0 ]; then
    echo "⚠️  No emulator/device found!"
    echo ""
    echo "Please start an emulator first:"
    echo "  - Android: Open Android Studio → AVD Manager → Start Emulator"
    echo "  - iOS: Run 'open -a Simulator'"
    echo ""
    echo "Or run: flutter emulators --launch <emulator-id>"
    echo ""
    exit 1
fi

# Run the app
echo "🚀 Starting the app..."
echo ""
echo "Hot Reload: Press 'r' to reload"
echo "Hot Restart: Press 'R' to restart"
echo "Quit: Press 'q' to quit"
echo ""

flutter run --debug

echo ""
echo "✨ App closed!"
