class AppConstants {
  // App Info
  static const String appName = 'Reading App';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Ứng dụng hỗ trợ đọc sách theo ngày và đạo';

  // Reading Categories
  static const List<String> categories = [
    'Phật giáo',
    'Đạo giáo',
    'Thiền định',
    'Triết học',
    'Lịch sử',
  ];

  // Difficulty Levels
  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  // Reading Goals (in minutes)
  static const List<int> readingGoals = [15, 30, 45, 60, 90, 120];

  // Notification Types
  static const List<String> notificationTypes = [
    'reading_reminder',
    'achievement',
    'update',
    'new_content',
  ];

  // Languages
  static const Map<String, String> languages = {
    'vi': 'Tiếng Việt',
    'en': 'English',
  };

  // Reading Modes
  static const List<String> readingModes = [
    'scroll',
    'page',
  ];

  // Font Sizes
  static const List<double> fontSizes = [12, 14, 16, 18, 20, 22, 24];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration longAnimation = Duration(milliseconds: 1000);

  // API Endpoints (if needed)
  static const String baseUrl = 'https://api.readingapp.com';
  static const String readingsEndpoint = '/readings';
  static const String notificationsEndpoint = '/notifications';

  // Storage Keys
  static const String userSettingsKey = 'user_settings';
  static const String readingProgressKey = 'reading_progress';
  static const String bookmarksKey = 'bookmarks';
  static const String notesKey = 'notes';
  static const String highlightsKey = 'highlights';

  // Default Values
  static const int defaultDailyReadingGoal = 30; // minutes
  static const String defaultLanguage = 'vi';
  static const String defaultDifficulty = 'Medium';
  static const double defaultFontSize = 16.0;
  static const String defaultReadingMode = 'scroll';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 20.0;

  // Error Messages
  static const String errorGeneric = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String errorNetwork =
      'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
  static const String errorNotFound = 'Không tìm thấy dữ liệu.';
  static const String errorSave = 'Lỗi khi lưu dữ liệu.';
  static const String errorLoad = 'Lỗi khi tải dữ liệu.';

  // Success Messages
  static const String successSave = 'Đã lưu thành công.';
  static const String successDelete = 'Đã xóa thành công.';
  static const String successUpdate = 'Đã cập nhật thành công.';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableSync = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
}
