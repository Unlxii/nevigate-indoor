# Indoor Navigation System 🧭

ระบบนำทางในอาคารด้วย UWB (Ultra-Wideband) Positioning โดยใช้ Flutter

## 🌟 คุณสมบัติหลัก

- 📍 **ระบุตำแหน่ง UWB**: ใช้ ESP WD-1000 ในการวัดระยะทางแบบ Real-time
- 📱 **Bluetooth Communication**: รับข้อมูลตำแหน่งผ่าน Bluetooth Low Energy
- 👥 **ระบบสิทธิ์**: แบ่งเป็น Admin และ Client ผ่าน Firebase Authentication
- 🗺️ **แผนที่ 2D**: แสดงผังอาคารพร้อมตำแหน่งปัจจุบัน
- 🔍 **ค้นหาห้อง**: ระบบค้นหาห้องและจุดหมายปลายทาง
- 🧭 **การนำทาง**: แสดงเส้นทางคล้าย Google Maps พร้อมระยะทางและเวลา
- 🏢 **รองรับหลายชั้น**: สามารถใช้งานกับอาคารหลายชั้น

## 🔧 เทคโนโลยีที่ใช้

- **Flutter** - Framework สำหรับพัฒนา Cross-platform
- **Firebase Authentication** - ระบบ Login/Register
- **Cloud Firestore** - ฐานข้อมูลสำหรับห้องและผู้ใช้
- **Flutter BLoC** - State Management
- **Flutter Blue Plus** - Bluetooth Communication
- **ESP WD-1000** - UWB Positioning Hardware

## 📋 ความต้องการของระบบ

### ฮาร์ดแวร์

- ESP WD-1000 อย่างน้อย 2 ตัว (Anchor)
- ESP WD-1000 1 ตัว (Receiver/Tag)
- อุปกรณ์ Android (API 21+) หรือ iOS (12.0+)

### ซอฟต์แวร์

- Flutter SDK (3.0.0 หรือสูงกว่า)
- Dart SDK
- Android Studio / Xcode
- Firebase Project

## 🚀 การติดตั้งและรัน Emulator

### วิธีที่ 1: ใช้ Script อัตโนมัติ (แนะนำ)

```bash
# 1. ติดตั้ง Flutter และ Android Studio
./setup.sh

# 2. เปิด emulator
./launch_emulator.sh

# 3. รันแอพ
./run_app.sh
```

### วิธีที่ 2: ติดตั้งแบบ Manual

#### 1. ติดตั้ง Flutter

```bash
# macOS
brew install --cask flutter

# เพิ่มใน PATH
echo 'export PATH="$PATH:/usr/local/Caskroom/flutter/latest/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# ตรวจสอบการติดตั้ง
flutter doctor
```

#### 2. ติดตั้ง Android Studio และ Emulator

```bash
# ติดตั้ง Android Studio
brew install --cask android-studio
```

**จากนั้นเปิด Android Studio:**

1. ไปที่ **More Actions** → **SDK Manager**
2. ติดตั้ง Android SDK (API 34 หรือล่าสุด)
3. ไปที่ **More Actions** → **Virtual Device Manager**
4. คลิก **Create Device** → เลือก Pixel 7 → เลือก Android 14
5. คลิก **Finish**

#### 3. Accept Android Licenses

```bash
flutter doctor --android-licenses
# กด 'y' เพื่อ accept ทุกข้อ
```

#### 4. เปิด Emulator และรันแอพ

```bash
# เปิด emulator จาก Android Studio AVD Manager
# หรือใช้คำสั่ง
flutter emulators --launch <emulator-id>

# รันแอพ
cd "/Users/tteenntt/CmuUniversity/OwnProject/project-survey/nevigate indoor"
flutter pub get
flutter run
```

### iOS Simulator (สำหรับ macOS)

```bash
# ติดตั้ง Xcode จาก App Store

# เปิด Simulator
open -a Simulator

# รันแอพ
flutter run
```

### 📖 คู่มือโดยละเอียด

- [คู่มือการติดตั้งและใช้งาน Emulator](docs/EMULATOR_GUIDE.md)
- [คู่มือการติดตั้งทั่วไป](INSTALLATION.md)

### 2. Clone โปรเจ็กต์

```bash
cd "/Users/tteenntt/CmuUniversity/OwnProject/project-survey/nevigate indoor"
```

### 3. ติดตั้ง Dependencies

```bash
flutter pub get
```

### 4. ตั้งค่า Firebase

1. สร้าง Firebase Project ที่ [Firebase Console](https://console.firebase.google.com/)
2. เพิ่ม Android App และ iOS App
3. ดาวน์โหลดไฟล์ configuration:
   - `google-services.json` สำหรับ Android → วางใน `android/app/`
   - `GoogleService-Info.plist` สำหรับ iOS → วางใน `ios/Runner/`
4. เปิดใช้งาน **Authentication** (Email/Password)
5. สร้าง **Cloud Firestore** Database

### 5. ตั้งค่า Admin Emails

แก้ไขไฟล์ `lib/core/config/app_config.dart`:

```dart
static const List<String> adminEmails = [
  'admin@example.com',  // เปลี่ยนเป็น email ของคุณ
];
```

### 6. เตรียม Firestore Database

สร้าง Collection ใน Firestore:

**Collection: `rooms`**

```json
{
  "id": "room_001",
  "name": "ห้อง 101",
  "description": "ห้องประชุม",
  "centerPosition": {
    "x": 10.0,
    "y": 5.0,
    "z": 0.0
  },
  "boundary": [
    { "x": 8.0, "y": 3.0, "z": 0.0 },
    { "x": 12.0, "y": 3.0, "z": 0.0 },
    { "x": 12.0, "y": 7.0, "z": 0.0 },
    { "x": 8.0, "y": 7.0, "z": 0.0 }
  ],
  "floor": 0
}
```

## 📱 การรันโปรแกรม

### Android

```bash
flutter run
```

### iOS

```bash
cd ios
pod install
cd ..
flutter run
```

### Build APK (Android)

```bash
flutter build apk --release
```

### Build IPA (iOS)

```bash
flutter build ios --release
```

## 🔌 การตั้งค่า ESP WD-1000

### Anchor (จุดอ้างอิง)

1. Flash firmware ให้ ESP WD-1000 ทำงานเป็น Anchor
2. ตั้งค่าตำแหน่งของแต่ละ Anchor ในระบบพิกัด
3. ตั้งค่า Bluetooth Name เป็น `ESP_UWB_A1`, `ESP_UWB_A2` เป็นต้น

### Receiver/Tag

1. Flash firmware ให้ ESP WD-1000 ทำงานเป็น Receiver
2. ตั้งค่าให้ส่งข้อมูลตำแหน่งผ่าน Bluetooth
3. รูปแบบข้อมูลที่ส่ง (JSON):

```json
{
  "x": 1.23,
  "y": 4.56,
  "z": 0.0,
  "accuracy": 0.15,
  "anchors": [
    { "id": "A1", "distance": 2.3, "rssi": -45 },
    { "id": "A2", "distance": 3.1, "rssi": -50 }
  ]
}
```

## 📖 โครงสร้างโปรเจ็กต์

```
lib/
├── core/                    # Core configuration
│   ├── config/             # App configuration
│   └── theme/              # Theme settings
├── data/                    # Data layer
│   ├── repositories/       # Data repositories
│   └── services/           # External services
├── domain/                  # Domain layer
│   └── entities/           # Business entities
├── presentation/            # Presentation layer
│   ├── bloc/               # BLoC state management
│   ├── screens/            # UI screens
│   └── widgets/            # Reusable widgets
└── main.dart               # Entry point
```

## 🎯 การใช้งาน

### สำหรับผู้ใช้ทั่วไป (Client)

1. เปิดแอพและ Login ด้วย Email
2. เชื่อมต่อ Bluetooth กับ ESP UWB Receiver
3. รอให้ระบบระบุตำแหน่ง
4. ค้นหาห้องที่ต้องการไป
5. ระบบจะแสดงเส้นทางไปยังจุดหมาย

### สำหรับผู้ดูแล (Admin)

1. Login ด้วย Admin Email
2. เข้าเมนู "จัดการ"
3. สามารถจัดการสิทธิ์ผู้ใช้
4. เปลี่ยนสถานะผู้ใช้

## 🐛 การแก้ปัญหา

### Bluetooth ไม่เชื่อมต่อ

1. ตรวจสอบว่าเปิด Bluetooth บนมือถือแล้ว
2. ตรวจสอบ Permissions (Location, Bluetooth)
3. ลอง Scan ใหม่

### ตำแหน่งไม่ถูกต้อง

1. ตรวจสอบว่ามี Anchor อย่างน้อย 2 ตัว
2. Calibrate ตำแหน่ง Anchor ใหม่
3. ตรวจสอบ Accuracy value

### Firebase Error

1. ตรวจสอบไฟล์ `google-services.json` / `GoogleService-Info.plist`
2. ตรวจสอบ Firebase Console settings
3. เปิดใช้งาน Authentication และ Firestore

## 📝 TODO

- [ ] รองรับการเปลี่ยนชั้น
- [ ] เพิ่มระบบ AR Navigation
- [ ] Offline mode
- [ ] History tracking
- [ ] Multi-language support
- [ ] Dark mode
- [ ] การจัดการห้องผ่าน Admin panel

## 👨‍💻 ผู้พัฒนา

ติดต่อ: [Your Email]
