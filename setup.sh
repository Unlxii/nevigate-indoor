#!/bin/bash

# Indoor Navigation - Setup Script
# สคริปต์สำหรับติดตั้งและตั้งค่าโปรเจ็กต์

echo "🚀 Starting Indoor Navigation Setup..."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed!"
    echo "📥 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "✅ Homebrew is installed"
echo ""

# Install Flutter
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    brew install --cask flutter
    
    # Add to PATH
    echo 'export PATH="$PATH:/usr/local/Caskroom/flutter/latest/flutter/bin"' >> ~/.zshrc
    source ~/.zshrc
    
    echo "✅ Flutter installed successfully"
else
    echo "✅ Flutter is already installed"
fi

echo ""

# Install Android Studio
if ! command -v /Applications/Android\ Studio.app/Contents/MacOS/studio &> /dev/null; then
    echo "📥 Installing Android Studio..."
    brew install --cask android-studio
    echo "✅ Android Studio installed"
    echo "⚠️  Please open Android Studio and complete the setup wizard"
    echo "   Then run this script again"
    exit 0
else
    echo "✅ Android Studio is already installed"
fi

echo ""

# Run Flutter Doctor
echo "🔍 Checking Flutter setup..."
flutter doctor

echo ""
echo "📝 Next Steps:"
echo "1. Open Android Studio"
echo "2. Go to More Actions → SDK Manager"
echo "3. Install Android SDK (API 34 or latest)"
echo "4. Go to More Actions → Virtual Device Manager"
echo "5. Create a new Virtual Device"
echo "6. Run: flutter doctor --android-licenses"
echo "7. Run: ./run_app.sh"
echo ""
echo "✨ Setup script completed!"
