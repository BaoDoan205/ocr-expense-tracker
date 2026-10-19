
# OCR Expense Tracker & Receipt Parser

Ứng dụng quản lý chi tiêu cá nhân trên Android,
sử dụng Flutter và OCR để nhận diện thông tin hóa đơn.

## Công nghệ sử dụng

- Flutter / Dart
- Google ML Kit Text Recognition
- Camera và Image Cropper
- Regex / Heuristics
- SQLite (sqflite)
- CustomPainter

## Chức năng chính

1. Chụp ảnh và cắt vùng hóa đơn.
2. Nhận diện văn bản bằng OCR.
3. Trích xuất tên cửa hàng, ngày và tổng tiền.
4. Cho phép chỉnh sửa thông tin trước khi lưu.
5. Lưu và quản lý giao dịch bằng SQLite.
6. Thống kê chi tiêu theo danh mục và thời gian.
7. Hiển thị biểu đồ tròn và biểu đồ cột.

## Kiến trúc ứng dụng

Camera
  → Image Cropper
  → OCR Service
  → Receipt Parser
  → Confirmation Screen
  → SQLite
  → Transactions / Statistics / Home

## Cài đặt

Yêu cầu Flutter SDK và Android SDK.

```bash
flutter pub get
flutter run
```

## Kiểm thử

```bash
flutter analyze
flutter test
```

## Build APK

```bash
flutter build apk --release
```

APK được tạo trong:

build/app/outputs/flutter-apk/

## Giới hạn

- Kết quả OCR phụ thuộc chất lượng ảnh.
- Dữ liệu trích xuất có thể cần người dùng xác nhận.
- Dữ liệu SQLite được lưu cục bộ trên thiết bị.
