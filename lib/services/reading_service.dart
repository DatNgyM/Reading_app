import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reading_item.dart';
import '../models/user_settings.dart';
import '../data/sample_data.dart';

class ReadingService {
  static const String _readingsKey = 'readings';
  static const String _progressKey = 'reading_progress';
  static const String _bookmarksKey = 'bookmarks';

  // Lấy tất cả bài đọc
  static Future<List<ReadingItem>> getAllReadings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingsJson = prefs.getStringList(_readingsKey);

      if (readingsJson != null && readingsJson.isNotEmpty) {
        return readingsJson
            .map((json) => ReadingItem.fromJson(jsonDecode(json)))
            .toList();
      }

      // Nếu chưa có dữ liệu, trả về sample data
      return SampleData.getAllReadings();
    } catch (e) {
      return SampleData.getAllReadings();
    }
  }

  // Lấy bài đọc hôm nay
  static Future<List<ReadingItem>> getTodayReadings() async {
    final allReadings = await getAllReadings();
    final today = DateTime.now();

    return allReadings.where((reading) {
      return reading.date.year == today.year &&
          reading.date.month == today.month &&
          reading.date.day == today.day;
    }).toList();
  }

  // Lấy bài đọc được đề xuất
  static Future<List<ReadingItem>> getRecommendedReadings() async {
    final allReadings = await getAllReadings();
    return allReadings.where((reading) => reading.rating >= 4.5).toList();
  }

  // Tìm kiếm bài đọc
  static Future<List<ReadingItem>> searchReadings(String query) async {
    final allReadings = await getAllReadings();
    if (query.isEmpty) return allReadings;

    return allReadings.where((reading) {
      return reading.title.toLowerCase().contains(query.toLowerCase()) ||
          reading.content.toLowerCase().contains(query.toLowerCase()) ||
          reading.author.toLowerCase().contains(query.toLowerCase()) ||
          reading.tags
              .any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Lọc theo danh mục
  static Future<List<ReadingItem>> filterByCategory(String category) async {
    final allReadings = await getAllReadings();
    if (category == 'Tất cả') return allReadings;

    return allReadings
        .where((reading) => reading.category == category)
        .toList();
  }

  // Lọc theo độ khó
  static Future<List<ReadingItem>> filterByDifficulty(String difficulty) async {
    final allReadings = await getAllReadings();
    if (difficulty == 'Tất cả') return allReadings;

    return allReadings
        .where((reading) => reading.difficulty == difficulty)
        .toList();
  }

  // Lấy bài đọc theo ID
  static Future<ReadingItem?> getReadingById(String id) async {
    final allReadings = await getAllReadings();
    try {
      return allReadings.firstWhere((reading) => reading.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cập nhật tiến độ đọc
  static Future<void> updateReadingProgress(
      String readingId, double progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = prefs.getString(_progressKey);
      Map<String, dynamic> progressData = {};

      if (progressMap != null) {
        progressData = jsonDecode(progressMap);
      }

      progressData[readingId] = {
        'progress': progress,
        'lastReadAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_progressKey, jsonEncode(progressData));
    } catch (e) {
      // Handle error
    }
  }

  // Lấy tiến độ đọc
  static Future<double> getReadingProgress(String readingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = prefs.getString(_progressKey);

      if (progressMap != null) {
        final progressData = jsonDecode(progressMap);
        return progressData[readingId]?['progress'] ?? 0.0;
      }

      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Đánh dấu hoàn thành
  static Future<void> markAsCompleted(String readingId) async {
    try {
      final allReadings = await getAllReadings();
      final updatedReadings = allReadings.map((reading) {
        if (reading.id == readingId) {
          return reading.copyWith(isCompleted: true, progress: 1.0);
        }
        return reading;
      }).toList();

      await _saveReadings(updatedReadings);
    } catch (e) {
      // Handle error
    }
  }

  // Thêm/xóa bookmark
  static Future<void> toggleBookmark(String readingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];

      if (bookmarks.contains(readingId)) {
        bookmarks.remove(readingId);
      } else {
        bookmarks.add(readingId);
      }

      await prefs.setStringList(_bookmarksKey, bookmarks);

      // Cập nhật trong danh sách bài đọc
      final allReadings = await getAllReadings();
      final updatedReadings = allReadings.map((reading) {
        if (reading.id == readingId) {
          return reading.copyWith(isBookmarked: bookmarks.contains(readingId));
        }
        return reading;
      }).toList();

      await _saveReadings(updatedReadings);
    } catch (e) {
      // Handle error
    }
  }

  // Lưu danh sách bài đọc
  static Future<void> _saveReadings(List<ReadingItem> readings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingsJson =
          readings.map((reading) => jsonEncode(reading.toJson())).toList();
      await prefs.setStringList(_readingsKey, readingsJson);
    } catch (e) {
      // Handle error
    }
  }
}

class SettingsService {
  static const String _settingsKey = 'user_settings';

  // Lưu cài đặt
  static Future<void> saveSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    } catch (e) {
      // Handle error
    }
  }

  // Lấy cài đặt
  static Future<UserSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        return UserSettings.fromJson(jsonDecode(settingsJson));
      }

      return UserSettings();
    } catch (e) {
      return UserSettings();
    }
  }

  // Cập nhật một cài đặt cụ thể
  static Future<void> updateSetting(String key, dynamic value) async {
    try {
      final settings = await getSettings();
      UserSettings updatedSettings;

      switch (key) {
        case 'darkMode':
          updatedSettings = settings.copyWith(darkMode: value);
          break;
        case 'language':
          updatedSettings = settings.copyWith(language: value);
          break;
        case 'notificationsEnabled':
          updatedSettings = settings.copyWith(notificationsEnabled: value);
          break;
        case 'dailyReadingGoal':
          updatedSettings = settings.copyWith(dailyReadingGoal: value);
          break;
        case 'preferredDifficulty':
          updatedSettings = settings.copyWith(preferredDifficulty: value);
          break;
        case 'favoriteCategories':
          updatedSettings = settings.copyWith(favoriteCategories: value);
          break;
        case 'autoPlayAudio':
          updatedSettings = settings.copyWith(autoPlayAudio: value);
          break;
        case 'fontSize':
          updatedSettings = settings.copyWith(fontSize: value);
          break;
        case 'enableHapticFeedback':
          updatedSettings = settings.copyWith(enableHapticFeedback: value);
          break;
        case 'readingMode':
          updatedSettings = settings.copyWith(readingMode: value);
          break;
        case 'enableBookmarks':
          updatedSettings = settings.copyWith(enableBookmarks: value);
          break;
        case 'enableNotes':
          updatedSettings = settings.copyWith(enableNotes: value);
          break;
        case 'enableHighlights':
          updatedSettings = settings.copyWith(enableHighlights: value);
          break;
        default:
          return;
      }

      await saveSettings(updatedSettings);
    } catch (e) {
      // Handle error
    }
  }
}
