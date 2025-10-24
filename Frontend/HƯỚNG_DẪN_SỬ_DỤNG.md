 📚 HƯỚNG DẪN SỬ DỤNG READING APP

 🎯 Tổng quan ứng dụng

Reading App là ứng dụng đọc sách hỗ trợ người dùng tìm bài đọc theo ngày và theo đạo (Phật giáo, Đạo giáo). Ứng dụng được thiết kế đặc biệt cho người lớn với giao diện thân thiện và dễ sử dụng.

 ✨ Tính năng chính:
- 📖 Đọc theo ngày - Chọn ngày và xem bài đọc phù hợp
- 🔍 Tìm kiếm thông minh - Tìm bài đọc theo từ khóa, tác giả, danh mục
- 📚 Thư viện cá nhân - Quản lý bài đọc đã lưu và hoàn thành
- 🔔 Thông báo nhắc nhở - Nhắc nhở đọc sách hàng ngày
- ⚙️ Cài đặt linh hoạt - Tùy chỉnh giao diện và trải nghiệm đọc

---

 🚀 HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY ỨNG DỤNG

 📋 Yêu cầu hệ thống

 Máy phát triển:
- Flutter SDK: 3.16.0 trở lên
- Dart SDK: 3.2.0 trở lên
- Android Studio hoặc VS Code với Flutter extension
- Git để clone repository

 Thiết bị Android:
- Android: 7.0 (API level 24) trở lên
- RAM: Tối thiểu 2GB
- Storage: Tối thiểu 100MB trống

 🔧 Cài đặt môi trường

 1. Cài đặt Flutter:
```bash
 Tải Flutter SDK từ https://flutter.dev/docs/get-started/install
 Giải nén và thêm vào PATH
export PATH="$PATH:`pwd`/flutter/bin"

 Kiểm tra cài đặt
flutter doctor
```

 2. Cài đặt Android Studio:
- Tải từ https://developer.android.com/studio
- Cài đặt Android SDK (API 24+)
- Cấu hình Android emulator hoặc kết nối thiết bị thật

 3. Cài đặt dependencies:
```bash
 Clone project
git clone <repository-url>
cd Reading

 Cài đặt dependencies
flutter pub get

 Kiểm tra thiết bị
flutter devices
```

 🏃‍♂️ Chạy ứng dụng

 Chạy trên Android:
```bash
 Chạy trên thiết bị được kết nối
flutter run -d <device-id>

 Chạy trên emulator
flutter run

 Chạy với hot reload
flutter run --hot
```

 Build APK:
```bash
 Build debug APK
flutter build apk --debug

 Build release APK
flutter build apk --release

 APK sẽ được tạo tại: build/app/outputs/flutter-apk/
```

---

 📱 HƯỚNG DẪN SỬ DỤNG ỨNG DỤNG

 🏠 Màn hình chính (Home)

 Thao tác nhanh:
- 📅 Đọc theo ngày: Chọn ngày và xem bài đọc phù hợp
- 📚 Thư viện: Xem tất cả bài đọc đã lưu
- 🧘 Thiền định: Tính năng thiền định (đang phát triển)

 Gợi ý bài đọc:
- Hiển thị các bài đọc được đề xuất theo sở thích
- Có thể bookmark hoặc đọc ngay

 📅 Đọc theo ngày

 Cách sử dụng:
1. Chọn ngày: Tap vào icon lịch để chọn ngày
2. Xem bài đọc: Ứng dụng sẽ hiển thị bài đọc phù hợp cho ngày đó
3. Câu nói hôm nay: Mỗi ngày có một câu nói ý nghĩa khác nhau

 Tính năng:
- Date Picker: Chọn ngày với giao diện tiếng Việt
- Daily Quote: Câu nói động theo ngày
- Reading List: Danh sách bài đọc cho ngày đã chọn

 🔍 Tìm kiếm

 Tìm kiếm cơ bản:
1. Nhập từ khóa: Gõ tên bài đọc, tác giả hoặc nội dung
2. Kết quả: Hiển thị danh sách bài đọc phù hợp
3. Lọc kết quả: Sử dụng bộ lọc danh mục và độ khó

 Bộ lọc nâng cao:
- Danh mục: Phật giáo, Đạo giáo, Triết học, Lịch sử
- Độ khó: Easy, Medium, Hard
- Thời gian đọc: 5-60 phút

 📚 Thư viện

 Thống kê:
- Tổng bài đọc: Số lượng bài đọc có sẵn
- Đã lưu: Bài đọc đã bookmark
- Hoàn thành: Bài đọc đã đọc xong

 Phân loại:
- Tất cả: Xem tất cả bài đọc
- Đã lưu: Chỉ bài đọc đã bookmark
- Hoàn thành: Chỉ bài đọc đã đọc xong

 📖 Màn hình đọc

 Điều khiển:
- 🔤 Cỡ chữ: Tăng/giảm kích thước chữ
- 🌙 Chế độ tối: Chuyển đổi theme sáng/tối
- ✅ Đánh dấu hoàn thành: Đánh dấu bài đã đọc
- 🔖 Bookmark: Lưu bài đọc yêu thích
- 📝 Ghi chú: Thêm ghi chú cá nhân
- 🎯 Highlight: Tô sáng đoạn quan trọng
- 🔊 Text-to-Speech: Đọc thành tiếng (đang phát triển)

 Tính năng đọc:
- Scroll mượt: Cuộn mượt mà khi đọc
- Progress bar: Thanh tiến độ đọc
- Auto-save: Tự động lưu vị trí đọc

 🔔 Thông báo

 Cài đặt thông báo:
- Bật/tắt thông báo: Kiểm soát nhận thông báo
- Thời gian nhắc nhở: Thiết lập giờ nhắc đọc sách
- Tần suất: Hàng ngày, hàng tuần

 Loại thông báo:
- Nhắc nhở đọc sách: Thông báo hàng ngày
- Bài đọc mới: Thông báo khi có bài mới
- Mục tiêu đọc: Nhắc nhở hoàn thành mục tiêu

 ⚙️ Cài đặt

 Giao diện:
- 🌙 Chế độ tối: Bật/tắt dark mode
- 🌍 Ngôn ngữ: Tiếng Việt/English
- 🎨 Theme: Tùy chỉnh màu sắc

 Tùy chọn đọc:
- ⏰ Mục tiêu đọc hàng ngày: 5-120 phút
- 📊 Độ khó ưa thích: Easy/Medium/Hard
- 📖 Chế độ đọc: Cuộn/Trang

 Tính năng:
- 🔊 Tự động phát audio: Bật/tắt
- 📳 Phản hồi xúc giác: Rung nhẹ khi tương tác
- 🔖 Bookmark: Bật/tắt tính năng lưu bài
- 📝 Ghi chú: Bật/tắt tính năng ghi chú
- 🎯 Highlight: Bật/tắt tính năng tô sáng

---

 🛠️ HƯỚNG DẪN PHÁT TRIỂN

 📁 Cấu trúc project

```
lib/
├── main.dart                  Entry point
├── models/                    Data models
│   ├── reading_item.dart
│   └── user_settings.dart
├── screens/                   UI screens
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── reading_screen.dart
│   ├── library_screen.dart
│   ├── notification_screen.dart
│   ├── settings_screen.dart
│   └── daily_reading_screen.dart
├── widgets/                   Reusable widgets
│   ├── custom_app_bar.dart
│   ├── reading_card.dart
│   ├── custom_bottom_navigation.dart
│   └── animated_widgets.dart
├── providers/                 State management
│   └── theme_provider.dart
├── data/                      Sample data
│   └── sample_data.dart
├── services/                  Business logic
│   └── reading_service.dart
├── utils/                     Utilities
│   └── app_theme.dart
└── assets/                    Static assets
    ├── images/
    └── icons/
```

 🔧 Cấu hình quan trọng

 pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^19.5.0
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  smooth_page_indicator: ^1.1.0
  flutter_staggered_animations: ^1.1.1
  shimmer: ^3.0.0
  provider: ^6.1.1
```

 Android build.gradle:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.example.reading_app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
        coreLibraryDesugaringEnabled true
    }
    kotlinOptions {
        jvmTarget = '17'
    }
}
```

 🎨 Customization

 Thay đổi theme:
```dart
// lib/utils/app_theme.dart
class AppTheme {
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF66BB6A);
  
  // Thay đổi màu sắc tại đây
}
```

 Thêm bài đọc mới:
```dart
// lib/data/sample_data.dart
static List<ReadingItem> getAllReadings() {
  return [
    ReadingItem(
      id: 'unique_id',
      title: 'Tên bài đọc',
      content: 'Nội dung bài đọc...',
      author: 'Tác giả',
      category: 'Danh mục',
      difficulty: 'Easy',
      readingTime: 15,
      tags: ['tag1', 'tag2'],
    ),
    // Thêm bài đọc khác...
  ];
}
```

 🐛 Debug và Troubleshooting

 Lỗi thường gặp:

1. Gradle build failed:
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean
   ```

2. Theme không hoạt động:
   - Kiểm tra ThemeProvider đã được wrap đúng cách
   - Đảm bảo SharedPreferences được khởi tạo

3. Icons không hiển thị:
   - Kiểm tra assets trong pubspec.yaml
   - Chạy `flutter pub get`

4. Navigation lỗi:
   - Kiểm tra Navigator context
   - Đảm bảo MaterialApp được wrap đúng

 Debug commands:
```bash
 Xem logs chi tiết
flutter run --verbose

 Debug trên thiết bị cụ thể
flutter run -d <device-id> --debug

 Hot reload
 Nhấn 'r' trong terminal khi app đang chạy

 Hot restart
 Nhấn 'R' trong terminal khi app đang chạy
```

---

 📞 HỖ TRỢ VÀ LIÊN HỆ

 🆘 Gặp vấn đề?

1. Kiểm tra logs: Xem console output để tìm lỗi
2. Restart app: Đóng và mở lại ứng dụng
3. Clear cache: Xóa cache ứng dụng trong Settings
4. Reinstall: Gỡ cài đặt và cài lại ứng dụng

 📧 Liên hệ phát triển

- Email: your.email@example.com
- GitHub: https://github.com/yourusername/reading-app
- Issues: Tạo issue trên GitHub repository

 🔄 Cập nhật

- Version: 1.0.0
- Last Update: 2024
- Next Update: Theo lịch phát triển

---

 📄 LICENSE

Dự án này được phát triển cho mục đích học tập và nghiên cứu. Vui lòng liên hệ để biết thêm chi tiết về license.

---

🎉 Chúc bạn có trải nghiệm đọc sách tuyệt vời với Reading App!
