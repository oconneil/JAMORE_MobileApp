# เชื่อมต่อ Local API บน iOS Simulator (HTTPS)

> ปัญหาที่เจอบ่อยตอน dev: รันแอปบน iOS Simulator แล้วต่อ `https://localhost:5001/api/`
> ไม่ติด ทั้งที่ backend (ASP.NET Core / Kestrel) รันอยู่ปกติ

## ต้นเหตุ

`dotnet dev-certs https --trust` ไป trust dev certificate แค่ใน **macOS keychain**
แต่ **iOS Simulator มี trust store แยกของตัวเอง** ไม่ได้ใช้ของ macOS

ผลคือ TLS handshake ระหว่างแอปกับ `https://localhost:5001` ถูก reject เพราะ simulator
ไม่เชื่อ cert → ต่อ API ไม่ติด (แม้ `curl` จากตัว Mac เองจะผ่าน เพราะ Mac เชื่อ cert แล้ว)

## วิธีแก้ — ติดตั้ง dev cert เข้า simulator โดยตรง

```bash
# 1. (ครั้งเดียว) trust cert ใน macOS + สร้าง cert ถ้ายังไม่มี
dotnet dev-certs https --trust

# 2. export dev cert เป็นไฟล์ PEM
dotnet dev-certs https --export-path "$HOME/jamore-localhost.cer" --format PEM

# 3. ติดตั้ง cert เข้า simulator ที่ boot อยู่
xcrun simctl keychain booted add-root-cert "$HOME/jamore-localhost.cer"

# 4. ปิดแอปแล้วรันใหม่ (hot restart ไม่พอ — ต้องเปิด connection ใหม่)
flutter run
```

config เดิมใน `lib/core/app_config.dart` ใช้ได้เลย ไม่ต้องแก้:
```dart
defaultValue: 'https://localhost:5001/api/',
```

## ข้อควรระวัง

- **Erase / reset simulator หรือเปลี่ยนเครื่อง** → ต้องรัน step 3 ซ้ำ
  ```bash
  xcrun simctl keychain booted add-root-cert ~/jamore-localhost.cer
  ```
- **Android Emulator** ใช้วิธีนี้ไม่ได้ — `localhost` ต้องเปลี่ยนเป็น `10.0.2.2`
  และจัดการเรื่อง cleartext/cert ต่างหาก
- **เครื่องจริง (physical device)** ใช้วิธีนี้ไม่ได้ — ต้องใช้ IP จริงของคอมใน LAN
  + ติดตั้ง cert ผ่าน configuration profile หรือสลับไปใช้ HTTP

## คำสั่งไล่เช็ค (debug checklist)

```bash
# backend listen อยู่บน 5001 ไหม
lsof -nP -iTCP:5001 -sTCP:LISTEN

# cert ถูก trust ใน macOS ไหม
dotnet dev-certs https --check --trust

# handshake จาก Mac ผ่านไหม (ควรได้ "SSL certificate verify ok")
curl -sv https://localhost:5001/api/

# simulator ที่ boot อยู่
xcrun simctl list devices booted
```
