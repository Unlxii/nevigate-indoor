# คู่มือการติดตั้ง Flutter และรัน Emulator

## ขั้นตอนที่ 1: ติดตั้ง Flutter

### วิธีที่ 1: ติดตั้งผ่าน Homebrew (แนะนำสำหรับ macOS)

```bash
# ติดตั้ง Flutter
brew install --cask flutter

# เพิ่ม Flutter ใน PATH (เพิ่มในไฟล์ ~/.zshrc)
echo 'export PATH="$PATH:/usr/local/Caskroom/flutter/latest/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# ตรวจสอบการติดตั้ง
flutter doctor
```

### วิธีที่ 2: ดาวน์โหลดและติดตั้งแบบ Manual

```bash
# ดาวน์โหลด Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# เพิ่มใน PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# ตรวจสอบ
flutter doctor
```

## ขั้นตอนที่ 2: ติดตั้ง Android Studio (สำหรับ Android Emulator)

### 1. ดาวน์โหลด Android Studio

```bash
# ติดตั้งผ่าน Homebrew
brew install --cask android-studio

# หรือดาวน์โหลดจาก
https://developer.android.com/studio
```

### 2. ติดตั้ง Android SDK

1. เปิด Android Studio
2. ไปที่ **More Actions** → **SDK Manager**
3. ติดตั้ง:
   - Android SDK Platform (API 34 หรือล่าสุด)
   - Android SDK Build-Tools
   - Android Emulator
   - Android SDK Platform-Tools

### 3. ตั้งค่า Environment Variables

```bash
# เพิ่มใน ~/.zshrc
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

### 4. Accept Android Licenses

```bash
flutter doctor --android-licenses
# กด 'y' เพื่อ accept ทุกข้อ
```

## ขั้นตอนที่ 3: สร้าง Android Emulator

### วิธีที่ 1: ผ่าน Android Studio (แนะนำ)

1. เปิด Android Studio
2. ไปที่ **More Actions** → **Virtual Device Manager** (หรือ AVD Manager)
3. คลิก **Create Device**
4. เลือกอุปกรณ์ (แนะนำ: Pixel 7 หรือ Pixel 8)
5. เลือก System Image (แนะนำ: Android 14 หรือล่าสุด)
6. คลิก **Next** → **Finish**

### วิธีที่ 2: ผ่าน Command Line

```bash
# แสดงรายการ emulator ที่มี
flutter emulators

# สร้าง emulator ใหม่
flutter emulators --create --name flutter_emulator

# หรือใช้ avdmanager
avdmanager create avd -n flutter_emulator -k "system-images;android-34;google_apis;x86_64"
```

## ขั้นตอนที่ 4: เปิด Emulator

### เปิดผ่าน Command Line

```bash
# แสดงรายการ emulator ทั้งหมด
flutter emulators

# เปิด emulator
flutter emulators --launch <emulator_id>

# หรือ
emulator -avd <emulator_name>
```

### เปิดผ่าน Android Studio

1. เปิด Android Studio
2. คลิก **More Actions** → **Virtual Device Manager**
3. คลิกปุ่ม ▶️ (Play) ข้าง emulator ที่ต้องการ

## ขั้นตอนที่ 5: รันแอพบน Emulator

```bash
# ไปยัง directory โปรเจ็กต์
cd "/Users/tteenntt/CmuUniversity/OwnProject/project-survey/nevigate indoor"

# ติดตั้ง dependencies
flutter pub get

# แสดงรายการ devices ที่พร้อมใช้งาน
flutter devices

# รันแอพ (จะรันบน emulator ที่เปิดอยู่อัตโนมัติ)
flutter run

# หรือระบุ device ID
flutter run -d <device_id>
```

## สำหรับ iOS Simulator (macOS เท่านั้น)

### 1. ติดตั้ง Xcode

```bash
# ติดตั้งผ่าน App Store
# หรือดาวน์โหลดจาก: https://developer.apple.com/xcode/

# ติดตั้ง Command Line Tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 2. เปิด iOS Simulator

```bash
# เปิด Simulator
open -a Simulator

# หรือผ่าน flutter
flutter emulators
flutter emulators --launch apple_ios_simulator
```

### 3. รันแอพบน iOS Simulator

```bash
flutter run
# จะรันบน iOS Simulator อัตโนมัติ
```

## Quick Start (ขั้นตอนย่อ)

```bash
# 1. ติดตั้ง Flutter
brew install --cask flutter

# 2. ติดตั้ง Android Studio
brew install --cask android-studio

# 3. เช็คสถานะ
flutter doctor

# 4. Accept licenses
flutter doctor --android-licenses

# 5. สร้าง emulator (ผ่าน Android Studio UI)
# More Actions → Virtual Device Manager → Create Device

# 6. รันโปรเจ็กต์
cd "/Users/tteenntt/CmuUniversity/OwnProject/project-survey/nevigate indoor"
flutter pub get
flutter run
```

## Tips & Tricks

### เช็คสถานะระบบ

```bash
flutter doctor -v
```

### แสดง devices ทั้งหมด

```bash
flutter devices
```

### รันบน device เฉพาะ

```bash
flutter run -d <device-id>
```

### Hot Reload (แก้โค้ดแล้วเห็นผลทันที)

- กด `r` ใน terminal ที่รัน `flutter run`
- หรือบันทึกไฟล์ (auto reload)

### Hot Restart

- กด `R` (ตัวพิมพ์ใหญ่) ใน terminal

### หยุดการรัน

- กด `q` ใน terminal

### Debug Mode

```bash
flutter run --debug
```

### Release Mode (เร็วกว่า)

```bash
flutter run --release
```

## แก้ปัญหาที่พบบ่อย

### 1. "Unable to locate Android SDK"

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
flutter doctor
```

### 2. "cmdline-tools component is missing"

- เปิด Android Studio → SDK Manager
- ไปที่ SDK Tools tab
- ติ๊ก "Android SDK Command-line Tools"
- คลิก Apply

### 3. Emulator ช้า

- เปิด Hardware Acceleration:
  ```bash
  # ตรวจสอบ HAXM (Intel) หรือ Hypervisor Framework
  flutter doctor
  ```
- เพิ่ม RAM และ Storage ใน AVD settings

### 4. "No devices found"

```bash
# ตรวจสอบว่า emulator เปิดอยู่
flutter devices

# เปิด emulator
flutter emulators --launch <emulator_id>
```

### 5. Build fails

```bash
# Clean และ rebuild
flutter clean
flutter pub get
flutter run
```

## ทางเลือกอื่นๆ

### 1. รันบนอุปกรณ์จริง (Physical Device)

**Android:**

1. เปิด Developer Options บนมือถือ
2. เปิด USB Debugging
3. เชื่อมต่อ USB cable
4. รัน `flutter run`

**iOS:**

1. เชื่อมต่อ iPhone/iPad
2. รัน `flutter run`
3. Trust device บนมือถือ

### 2. Flutter Web

```bash
flutter run -d chrome
```

### 3. Desktop (macOS/Windows/Linux)

```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## Performance Tips

### ทำให้ emulator เร็วขึ้น:

1. ใช้ x86_64 image (ไม่ใช่ ARM)
2. เปิด Hardware Acceleration
3. จำกัด RAM ไม่เกิน 2-4GB
4. ใช้ Cold Boot แทน Quick Boot

### ทำให้การ build เร็วขึ้น:

```bash
# เปิด Gradle Daemon
echo "org.gradle.daemon=true" >> android/gradle.properties
echo "org.gradle.parallel=true" >> android/gradle.properties
```

## Resources

- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
- [Android Studio Download](https://developer.android.com/studio)
- [Xcode Download](https://developer.apple.com/xcode/)
- [Flutter Doctor](https://docs.flutter.dev/get-started/install/macos#run-flutter-doctor)

## การใช้งาน VS Code (แนะนำ)

### ติดตั้ง Extensions:

1. Flutter
2. Dart

### รัน Emulator จาก VS Code:

1. กด `Cmd+Shift+P` (macOS) หรือ `Ctrl+Shift+P` (Windows/Linux)
2. พิมพ์ "Flutter: Launch Emulator"
3. เลือก emulator ที่ต้องการ
4. กด F5 เพื่อรันแอพ

---

หากมีปัญหาในการติดตั้งหรือรัน emulator สามารถถามได้เลยครับ! 😊
