 📖 READING APP - TỔNG QUAN DỰ ÁN

 🎯 Mô Tả Dự Án

Reading App là ứng dụng hỗ trợ đọc Kinh Thánh và bài đọc phụng vụ Công Giáo theo ngày. App được thiết kế cho người lớn, tập trung vào trải nghiệm đọc sâu và tiện lợi.



 📱 CẤU TRÚC ỨNG DỤNG

 🎨 Giao Diện Chính

 1. Home Screen (Màn hình chính)
- Chức năng chính:
  - Hiển thị lịch phụng vụ 2025 (từ ngày 1/1 → 31/12/2025)
  - Chọn ngày trên calendar để xem bài đọc
  - Hiển thị Thánh/Bổn mạng của ngày
  - Danh sách các bài đọc trong Thánh Lễ:
    - Bài Đọc 1
    - Bài Đọc 2
    - Tin Mừng
  
- UI Features:
  - Calendar hiện đại (table_calendar package)
  - Chuyển đổi xem theo tuần/tháng
  - Nút "Về hôm nay" để quay lại ngày hiện tại
  - Nút Yêu thích, Tìm kiếm ở thanh trên



 2. Daily Reading Screen (Màn hình đọc chi tiết)
- Chức năng:
  - Hiển thị nội dung đầy đủ của tất cả bài đọc trong ngày
  - Mỗi bài đọc là một ExpansionTile (có thể mở/đóng)
  - Chức năng Text-to-Speech (TTS) - Đọc thành tiếng

- TTS Features (Tính năng nổi bật):
  -  Play/Pause: Dừng/phát lại bài đọc
  -  Resume chính xác: Khi thoát ra và quay lại, TTS sẽ tiếp tục từ đúng vị trí đã dừng
  -  Theo dõi vị trí: Highlight ký tự đang được đọc
  -  Lưu trạng thái: Tự động lưu vị trí đọc vào SharedPreferences
  -  Dialog tiếp tục: Khi quay lại, app hỏi có muốn tiếp tục nghe không

- Kỹ thuật:
  - Dùng `flutter_tts` package
  - `setProgressHandler` để track vị trí chính xác
  - Lưu state bằng SharedPreferences
  - Offset tracking để resume đúng vị trí



 3. Search Screen (Tìm kiếm Kinh Thánh)
- Chức năng:
  - Tìm kiếm câu Kinh Thánh theo định dạng:
    - `Gioan 1:1-10` (Sách Chương:Câu-Câu)
    - `Luca 2, 2-24` (Sách Chương, Câu-Câu)
    - `Matthêu 5` (Chỉ chương)
  
- Dữ liệu:
  - Load từ `assets/data/Cuu_uoc.json` (Cựu Ước)
  - Load từ `assets/data/Tan_uoc.json` (Tân Ước)

- Features:
  - Hiển thị kết quả theo từng câu
  - Nút Yêu thích cho mỗi câu để lưu lại
  - Scroll để xem toàn bộ nội dung



 4. Favorites Screen (Màn hình yêu thích)
- Chức năng:
  - Lưu các câu Kinh Thánh được đánh dấu yêu thích từ Search Screen
  - Xem danh sách yêu thích đã lưu
  - Xóa yêu thích

- Storage:
  - Lưu vào SharedPreferences
  - Format: JSON với title, content, timestamp



 5. Library Screen (Thư viện PDF)
- Chức năng:
  - Xem PDF Kinh Thánh:
    - `eBookKinhThanhCuuUoc.pdf` (Cựu Ước)
    - `eBookKinhThanhTanUoc.pdf` (Tân Ước)
    - `lich-cong-giao-2025-all.pdf` (Lịch Công Giáo 2025)
  
- Features:
  - Đọc PDF trực tiếp trong app
  - Dùng `flutter_pdfview` package



 6. Settings Screen (Cài đặt)
- Chức năng:
  - Chuyển đổi theme sáng/tối
  - Cài đặt ngôn ngữ
  - Cài đặt thông báo
  - Cài đặt đọc (font size, etc.)



 7. Login/Register Screens (Đăng nhập/Đăng ký)
- Chức năng:
  - Đăng ký tài khoản mới
  - Đăng nhập vào app
  - Quản lý user bằng AuthService



 8. Notification Screen (Thông báo)
- Chức năng:
  - Xem danh sách thông báo
  - Thông báo nhắc nhở đọc sách



 9. Admin Screen (Dành cho admin)
- Chức năng:
  - Quản lý nội dung
  - Xem thống kê






 🔧 TECHNICAL STACK

 Core Frameworks
- Flutter: Cross-platform mobile development
- Dart: Programming language
- Provider: State management

 Key Packages
```yaml
dependencies:
   UI & Navigation
  flutter_localizations: SDK
  google_fonts: ^6.1.0
  table_calendar: ^3.1.2
  
   Storage & Data
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
   Features
  flutter_tts: ^3.8.5                     Text-to-Speech
  flutter_local_notifications: ^19.5.0    Notifications
  flutter_pdfview: ^1.3.2                 PDF Reader
  file_picker: ^8.0.0+1                   File picker
  
   Utilities
  intl: 0.20.2                            Internationalization
  flutter_staggered_animations: ^1.1.1    Animations
  shimmer: ^3.0.0                         Loading shimmer
```



 📁 CẤU TRÚC DỮ LIỆU

 Data Files (assets/data/)
```
assets/data/
  ├── lich_cong_giao_2025.json     Lịch phụng vụ cả năm 2025
  ├── Cuu_uoc.json                 Toàn bộ Cựu Ước
  └── Tan_uoc.json                 Toàn bộ Tân Ước
```

 PDF Files (assets/pdfs/)
```
assets/pdfs/
  ├── eBookKinhThanhCuuUoc.pdf            PDF Cựu Ước
  ├── eBookKinhThanhTanUoc.pdf            PDF Tân Ước
  └── lich-cong-giao-2025-all.pdf         PDF Lịch Công Giáo 2025
```

 Services
```
lib/services/
  ├── auth_service.dart                 Authentication
  ├── json_liturgical_service.dart      Load JSON lịch phụng vụ
  ├── bible_pdf_service.dart            Xử lý PDF Kinh Thánh
  ├── reading_service.dart              CRUD reading data
  └── tts_service.dart                  Text-to-Speech
```

 Models
```
lib/models/
  ├── daily_reading.dart         Model cho daily readings
  ├── reading_item.dart          Model cho reading items
  ├── user_settings.dart         User settings
  ├── user.dart                  User model
  └── ...
```



 🎯 TÍNH NĂNG NỔI BẬT

 1. Resume Reading Chính Xác ⭐⭐⭐
- Vấn đề ban đầu: TTS chạy tiếp sau khi thoát ra
- Giải pháp: Implement resume chính xác từ đúng vị trí đã dừng
- Kỹ thuật:
  - Dùng `setProgressHandler` để track vị trí
  - Lưu offset và character position
  - Dialog hỏi tiếp tục khi quay lại
  - Highlight ký tự đang đọc

 2. Tích Hợp Lịch Phụng Vụ 2025
- Load từ JSON file
- Calendar navigation
- Hiển thị theo ngày

 3. Tìm Kiếm Kinh Thánh Thông Minh
- Hỗ trợ nhiều định dạng input
- Tìm trong cả Cựu Ước và Tân Ước
- Nhanh và chính xác

 4. Yêu Thích & Bookmarking
- Lưu câu Kinh Thánh yêu thích
- Persistent storage với SharedPreferences
- Dễ dàng xem lại



 🎨 UI/UX FEATURES

 Theme System
- Light mode / Dark mode
- Tự động chuyển đổi
- Màu sắc nhất quán

 Animations
- Fade transitions
- Staggered animations
- Smooth scrolling

 Responsive Design
- Hoạt động tốt trên mobile
- Tablet support
- Adaptive layouts



 📊 DỮ LIỆU VÀ STORAGE

 Local Storage (SharedPreferences)
- User settings
- Reading progress
- Favorites
- TTS state

 Data Loading
- JSON files từ assets
- PDF files từ assets
- Caching để tăng performance



 🚀 DEPLOYMENT

 Platform Support
-  Android (đã test)
- ⚠️ iOS (chưa test đầy đủ)
- ⚠️ Windows (có lỗi Visual Studio)

 Build
```bash
 Android
flutter build apk

 iOS
flutter build ios

 Windows
flutter build windows
```



 <!-- 📝 TODO & FUTURE FEATURES

 Có thể thêm:
- [ ] Offline mode hoàn toàn
- [ ] Sync data lên cloud
- [ ] Multi-language support (Anh, Việt)
- [ ] Reading statistics
- [ ] Social sharing
- [ ] Prayer reminders
- [ ] Daily verse widget -->



 <!-- 🐛 KNOWN ISSUES -->

<!-- 1. Windows build: Thiếu Visual Studio components
2. iOS: Chưa test đầy đủ -->



 📄 LICENSE

Private project - All rights reserved



Version: 1.0.0  
Last Updated: January 2025  
Developed with Flutter ❤️

