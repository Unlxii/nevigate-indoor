#!/bin/bash

# Indoor Navigation - Emulator Launcher
# สคริปต์สำหรับเปิด emulator

echo "📱 Indoor Navigation - Emulator Launcher"
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please run: ./setup.sh first"
    exit 1
fi

# List available emulators
echo "Available emulators:"
flutter emulators
echo ""

# Prompt user to select emulator
read -p "Enter emulator ID to launch (or press Enter to skip): " EMULATOR_ID

if [ -z "$EMULATOR_ID" ]; then
    echo "⚠️  No emulator selected"
    echo ""
    echo "You can also launch emulator manually:"
    echo "  - Android Studio → AVD Manager → Start Emulator"
    echo "  - iOS: open -a Simulator"
    exit 0
fi

# Launch emulator
echo "🚀 Launching emulator: $EMULATOR_ID"
flutter emulators --launch "$EMULATOR_ID"

echo ""
echo "✅ Emulator launched!"
echo "Now run: ./run_app.sh"
