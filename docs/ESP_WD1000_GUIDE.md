# ESP WD-1000 Configuration Guide

## Overview

คู่มือการตั้งค่า ESP WD-1000 สำหรับระบบนำทางในอาคาร

## Hardware Requirements

- ESP WD-1000 modules (อย่างน้อย 3 ตัว)
- USB Cable สำหรับ Programming
- Power Supply 3.3V-5V

## Firmware Configuration

### Anchor Configuration (จุดอ้างอิง)

Anchor คือจุดอ้างอิงที่ติดตั้งไว้ในตำแหน่งคงที่

```cpp
// Anchor Configuration
#define DEVICE_TYPE "ANCHOR"
#define ANCHOR_ID "A1"  // A1, A2, A3, ...
#define ANCHOR_X 0.0    // ตำแหน่ง X (เมตร)
#define ANCHOR_Y 0.0    // ตำแหน่ง Y (เมตร)
#define ANCHOR_Z 2.5    // ความสูง (เมตร)

// Bluetooth Configuration
#define BLE_NAME "ESP_UWB_A1"
#define BLE_ADVERTISE true
```

### Tag/Receiver Configuration (ตัวรับ)

Tag คือตัวที่ติดกับผู้ใช้และส่งข้อมูลตำแหน่งไปยัง Application

```cpp
// Tag Configuration
#define DEVICE_TYPE "TAG"
#define TAG_ID "T1"

// Bluetooth Configuration
#define BLE_NAME "ESP_UWB_T1"
#define BLE_SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define BLE_CHAR_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// Update Rate
#define POSITION_UPDATE_MS 100  // 10 Hz
```

## Data Format

### Position Data (Tag → App)

```json
{
  "x": 1.23,
  "y": 4.56,
  "z": 0.0,
  "accuracy": 0.15,
  "timestamp": 1234567890,
  "anchors": [
    {
      "id": "A1",
      "distance": 2.3,
      "rssi": -45
    },
    {
      "id": "A2",
      "distance": 3.1,
      "rssi": -50
    },
    {
      "id": "A3",
      "distance": 1.8,
      "rssi": -42
    }
  ]
}
```

### Calibration Command (App → Tag)

```json
{
  "command": "calibrate",
  "anchors": [
    {
      "id": "A1",
      "position": {
        "x": 0.0,
        "y": 0.0,
        "z": 2.5
      }
    },
    {
      "id": "A2",
      "position": {
        "x": 10.0,
        "y": 0.0,
        "z": 2.5
      }
    },
    {
      "id": "A3",
      "position": {
        "x": 10.0,
        "y": 10.0,
        "z": 2.5
      }
    }
  ]
}
```

### Status Request (App → Tag)

```json
{
  "command": "status"
}
```

### Status Response (Tag → App)

```json
{
  "status": "ok",
  "battery": 85,
  "anchorsVisible": 3,
  "firmware": "1.0.0"
}
```

## Installation Guide

### ขั้นตอนที่ 1: ติดตั้ง Anchors

1. **วางแผนตำแหน่ง Anchors**

   - ติดตั้งอย่างน้อย 3 จุด เพื่อความแม่นยำในการคำนวณตำแหน่ง 2D
   - ติดตั้ง 4 จุดขึ้นไป สำหรับตำแหน่ง 3D
   - หลีกเลี่ยงสิ่งกีดขวางระหว่าง Anchors

2. **ตัวอย่างการวาง Anchors**

   ```
   ชั้น 1 (พื้นที่ 20x20 เมตร):

   A1 (0, 0, 2.5)          A2 (20, 0, 2.5)
        ●                       ●




   A3 (0, 20, 2.5)         A4 (20, 20, 2.5)
        ●                       ●
   ```

3. **Flash Firmware**
   - แต่ละ Anchor ต้องมี ID ไม่ซ้ำกัน (A1, A2, A3, ...)
   - บันทึกตำแหน่งที่แน่นอนของแต่ละ Anchor

### ขั้นตอนที่ 2: ตั้งค่า Tag/Receiver

1. Flash firmware สำหรับ Tag
2. ตั้งค่า Bluetooth parameters
3. ทดสอบการรับสัญญาณจาก Anchors

### ขั้นตอนที่ 3: Calibration

1. เปิดแอพ Indoor Navigation
2. Login เป็น Admin
3. ไปที่เมนู Calibration (ถ้ามี)
4. ส่งข้อมูลตำแหน่ง Anchors ไปยัง Tag

## Troubleshooting

### ปัญหา: ระบุตำแหน่งไม่ได้

**สาเหตุและแก้ไข:**

- ❌ Anchor น้อยกว่า 2 จุด → ติดตั้ง Anchor เพิ่ม
- ❌ สัญญาณถูกบัง → ย้าย Anchor หรือลบสิ่งกีดขวาง
- ❌ Anchor ไม่ทำงาน → ตรวจสอบไฟเลี้ยง

### ปัญหา: ตำแหน่งไม่แม่นยำ

**สาเหตุและแก้ไข:**

- ❌ ตำแหน่ง Anchor ไม่ถูกต้อง → Calibrate ใหม่
- ❌ Multipath interference → เพิ่มความสูงของ Anchor
- ❌ Tag ไกล Anchor เกินไป → เพิ่ม Anchor

### ปัญหา: Bluetooth ไม่เชื่อมต่อ

**สาเหตุและแก้ไข:**

- ❌ ชื่ออุปกรณ์ไม่ถูกต้อง → ตรวจสอบ BLE_NAME
- ❌ UUID ไม่ตรงกัน → ตรวจสอบ Service/Characteristic UUID
- ❌ Range เกินไป → เข้าใกล้อุปกรณ์มากขึ้น

## Performance Optimization

### 1. อัตราการอัพเดท

- **10 Hz (100ms)**: การใช้งานทั่วไป
- **20 Hz (50ms)**: การเคลื่อนที่เร็ว
- **5 Hz (200ms)**: ประหยัดพลังงาน

### 2. Filter Algorithm

แนะนำให้ใช้ Kalman Filter หรือ Moving Average เพื่อลดความผิดพลาด

### 3. Power Management

- ใช้ Sleep mode เมื่อไม่ใช้งาน
- ลด Bluetooth transmission power
- ปรับ update rate ตามความเหมาะสม

## Security Considerations

1. **Encryption**: เปิดใช้งาน Bluetooth Encryption
2. **Authentication**: ใช้ Pairing/Bonding
3. **Data Validation**: ตรวจสอบข้อมูลก่อนใช้งาน

## References

- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/)
- [DW1000 User Manual](https://www.decawave.com/)
- [UWB Positioning Guide](https://www.qorvo.com/design-hub/ebooks/uwb)

## Sample Code

ตัวอย่างโค้ดสำหรับ ESP WD-1000 สามารถดูได้ที่:

- `/docs/esp_code_examples/`

## Contact

หากมีปัญหาการใช้งาน กรุณาติดต่อ:

- Email: support@example.com
- GitHub Issues: [Link to Issues]
