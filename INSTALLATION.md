# คู่มือการติดตั้ง Flutter และการรันโปรเจ็กต์

## ขั้นตอนที่ 1: ติดตั้ง Flutter

### สำหรับ macOS:

```bash
# ติดตั้งผ่าน Homebrew
brew install --cask flutter

# หรือดาวน์โหลดจาก
https://docs.flutter.dev/get-started/install/macos
```

### ตรวจสอบการติดตั้ง:

```bash
flutter doctor
```

## ขั้นตอนที่ 2: ติดตั้ง Dependencies

```bash
cd "/Users/tteenntt/CmuUniversity/OwnProject/project-survey/nevigate indoor"
flutter pub get
```

## ขั้นตอนที่ 3: ตั้งค่า Firebase

### 3.1 สร้าง Firebase Project

1. ไปที่ https://console.firebase.google.com/
2. คลิก "Add project"
3. ตั้งชื่อโปรเจ็กต์เป็น "Indoor Navigation"

### 3.2 เพิ่ม Android App

1. คลิก "Add app" → เลือก Android
2. Android package name: `com.example.indoor_navigation`
3. ดาวน์โหลด `google-services.json`
4. วางไฟล์ที่: `android/app/google-services.json`

### 3.3 เพิ่ม iOS App

1. คลิก "Add app" → เลือก iOS
2. iOS bundle ID: `com.example.indoorNavigation`
3. ดาวน์โหลด `GoogleService-Info.plist`
4. วางไฟล์ที่: `ios/Runner/GoogleService-Info.plist`

### 3.4 เปิดใช้งาน Services

1. ไปที่ Authentication → Sign-in method
2. เปิดใช้งาน "Email/Password"
3. ไปที่ Firestore Database → Create database
4. เลือก "Start in test mode"

## ขั้นตอนที่ 4: ตั้งค่า Admin Email

แก้ไขไฟล์ `lib/core/config/app_config.dart`:

```dart
static const List<String> adminEmails = [
  'your_admin@email.com',  // ใส่ email ของคุณที่นี่
];
```

## ขั้นตอนที่ 5: สร้างข้อมูลตัวอย่าง

เพิ่มข้อมูลห้องใน Firestore:

1. ไปที่ Firestore Database
2. สร้าง Collection ชื่อ `rooms`
3. เพิ่ม Document ตัวอย่าง:

```json
{
  "id": "room_101",
  "name": "ห้อง 101",
  "description": "ห้องประชุม",
  "centerPosition": {
    "x": 10.0,
    "y": 5.0,
    "z": 0.0,
    "timestamp": "2024-01-01T00:00:00.000Z",
    "accuracy": 0.0
  },
  "boundary": [
    {
      "x": 8.0,
      "y": 3.0,
      "z": 0.0,
      "timestamp": "2024-01-01T00:00:00.000Z",
      "accuracy": 0.0
    },
    {
      "x": 12.0,
      "y": 3.0,
      "z": 0.0,
      "timestamp": "2024-01-01T00:00:00.000Z",
      "accuracy": 0.0
    },
    {
      "x": 12.0,
      "y": 7.0,
      "z": 0.0,
      "timestamp": "2024-01-01T00:00:00.000Z",
      "accuracy": 0.0
    },
    {
      "x": 8.0,
      "y": 7.0,
      "z": 0.0,
      "timestamp": "2024-01-01T00:00:00.000Z",
      "accuracy": 0.0
    }
  ],
  "floor": 0
}
```

## ขั้นตอนที่ 6: รันโปรเจ็กต์

### รันบน Android:

```bash
flutter run
```

### รันบน iOS:

```bash
cd ios
pod install
cd ..
flutter run
```

## ขั้นตอนที่ 7: Build APK/IPA

### Android (APK):

```bash
flutter build apk --release
# ไฟล์จะอยู่ที่: build/app/outputs/flutter-apk/app-release.apk
```

### iOS (IPA):

```bash
flutter build ios --release
# ต้อง Archive ผ่าน Xcode
```

## การแก้ปัญหาที่พบบ่อย

### 1. Flutter command not found

```bash
# เพิ่ม Flutter ใน PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. CocoaPods ไม่ทำงาน (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
```

### 3. Android License ไม่ได้ Accept

```bash
flutter doctor --android-licenses
```

### 4. Bluetooth Permission Error

- ตรวจสอบ AndroidManifest.xml และ Info.plist
- รัน `flutter clean` แล้ว rebuild

## การเชื่อมต่อ ESP WD-1000

1. เปิด Bluetooth บนมือถือ
2. เปิดแอพ Indoor Navigation
3. Login ด้วย Email
4. ระบบจะค้นหา ESP UWB Device อัตโนมัติ
5. เลือกอุปกรณ์ที่มีชื่อเริ่มต้นด้วย "ESP*UWB*"

## ข้อมูลเพิ่มเติม

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)
