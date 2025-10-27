import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/daily_reading.dart';

class JsonLiturgicalService {
  static Map<String, DailyReading>? _cachedReadings;

  /// Đọc dữ liệu từ file JSON
  static Future<Map<String, DailyReading>> loadFromJson() async {
    if (_cachedReadings != null) return _cachedReadings!;

    Map<String, DailyReading> readings = {};

    try {
      // Đọc file JSON
      final String jsonString = await rootBundle.loadString(
        'assets/data/lich_cong_giao_2025.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Parse từng ngày
      for (String dateKey in jsonData.keys) {
        final dateData = jsonData[dateKey];

        if (dateData == null || dateData is! Map<String, dynamic>) {
          continue;
        }

        final String saintName = dateData['saintName'] ?? '';
        final List<dynamic> readingsData = dateData['readings'] ?? [];

        List<ReadingReference> readingsList = [];

        for (var readingData in readingsData) {
          if (readingData == null || readingData is! Map<String, dynamic>) {
            continue;
          }

          final String type = readingData['type'] ?? '';
          final String book = readingData['book'] ?? '';
          final String chapters = readingData['chapters'] ?? '';
          final String pdfFile =
              readingData['pdfFile'] ?? 'eBookKinhThanhCuuUoc.pdf';

          // Bỏ qua nếu thiếu thông tin
          if (book.isEmpty || chapters.isEmpty) {
            continue;
          }

          readingsList.add(ReadingReference(
            type: type,
            book: book,
            chapters: chapters,
            pdfFile: pdfFile,
          ));
        }

        // Chỉ thêm nếu có bài đọc hoặc có tên thánh
        if (readingsList.isNotEmpty || saintName.isNotEmpty) {
          readings[dateKey] = DailyReading(
            date: dateKey,
            saintName: saintName.isEmpty ? 'Ngày thường' : saintName,
            readings: readingsList,
            note: dateData['note'],
          );
        }
      }

      _cachedReadings = readings;
      print('✅ Loaded ${readings.length} days from JSON');
    } catch (e) {
      print('❌ Error loading JSON data: $e');
    }

    return readings;
  }

  /// Lấy bài đọc hôm nay
  static Future<DailyReading?> getTodayReading() async {
    final today = DateTime.now();
    return getReadingForDate(today);
  }

  /// Lấy bài đọc theo ngày cụ thể
  static Future<DailyReading?> getReadingForDate(DateTime date) async {
    final readings = await loadFromJson();
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    return readings[dateKey];
  }

  /// Lấy bài đọc trong khoảng thời gian
  static Future<List<DailyReading>> getReadingsForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final readings = await loadFromJson();
    List<DailyReading> result = [];

    for (DateTime date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final reading = readings[dateKey];
      if (reading != null) {
        result.add(reading);
      }
    }

    return result;
  }

  /// Lấy bài đọc theo tháng
  static Future<List<DailyReading>> getReadingsForMonth(
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Ngày cuối tháng

    return getReadingsForRange(startDate, endDate);
  }

  /// In ra bài đọc hôm nay (cho debugging)
  static Future<void> printTodayReading() async {
    final todayReading = await getTodayReading();

    if (todayReading != null) {
      print('\n📖 BÀI ĐỌC HÔM NAY - ${todayReading.date}');
      print('🎭 ${todayReading.saintName}');
      print('─' * 50);

      for (var reading in todayReading.readings) {
        print('📚 ${reading.type}: ${reading.fullReference}');
        print('   📄 File: ${reading.pdfFile}');
      }
      print('─' * 50);
    } else {
      print('❌ Không tìm thấy bài đọc cho hôm nay');
    }
  }

  /// In ra bài đọc theo ngày
  static Future<void> printReadingForDate(DateTime date) async {
    final reading = await getReadingForDate(date);
    final dateStr = DateFormat('dd/MM/yyyy').format(date);

    if (reading != null) {
      print('\n📖 BÀI ĐỌC NGÀY $dateStr');
      print('🎭 ${reading.saintName}');
      print('─' * 50);

      for (var readingItem in reading.readings) {
        print('📚 ${readingItem.type}: ${readingItem.fullReference}');
        print('   📄 File: ${readingItem.pdfFile}');
      }
      print('─' * 50);
    } else {
      print('❌ Không tìm thấy bài đọc cho ngày $dateStr');
    }
  }

  /// In ra bài đọc trong tháng
  static Future<void> printReadingsForMonth(int year, int month) async {
    final readings = await getReadingsForMonth(year, month);

    print('\n📅 BÀI ĐỌC THÁNG $month/$year');
    print('═' * 60);

    for (var reading in readings) {
      print('\n📖 ${reading.date} - ${reading.saintName}');
      for (var readingItem in reading.readings) {
        print('   📚 ${readingItem.type}: ${readingItem.fullReference}');
      }
    }
    print('\n═' * 60);
    print('Tổng: ${readings.length} ngày');
  }

  /// Tìm kiếm bài đọc theo sách
  static Future<List<DailyReading>> searchByBook(String bookName) async {
    final readings = await loadFromJson();
    List<DailyReading> result = [];

    for (var reading in readings.values) {
      bool hasBook = reading.readings.any(
        (r) => r.book.toLowerCase().contains(bookName.toLowerCase()),
      );

      if (hasBook) {
        result.add(reading);
      }
    }

    return result;
  }

  /// Tìm kiếm bài đọc theo tên thánh
  static Future<List<DailyReading>> searchBySaint(String saintName) async {
    final readings = await loadFromJson();
    List<DailyReading> result = [];

    for (var reading in readings.values) {
      if (reading.saintName.toLowerCase().contains(saintName.toLowerCase())) {
        result.add(reading);
      }
    }

    return result;
  }

  /// Thống kê số lượng bài đọc theo sách
  static Future<Map<String, int>> getReadingStats() async {
    final readings = await loadFromJson();
    Map<String, int> stats = {};

    for (var reading in readings.values) {
      for (var readingItem in reading.readings) {
        stats[readingItem.book] = (stats[readingItem.book] ?? 0) + 1;
      }
    }

    // Sắp xếp theo số lần xuất hiện
    var sortedStats = Map.fromEntries(
      stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sortedStats;
  }

  /// Thống kê số lượng bài đọc theo loại
  static Future<Map<String, int>> getReadingTypeStats() async {
    final readings = await loadFromJson();
    Map<String, int> stats = {};

    for (var reading in readings.values) {
      for (var readingItem in reading.readings) {
        stats[readingItem.type] = (stats[readingItem.type] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Lấy danh sách các ngày có bài đọc
  static Future<List<String>> getAvailableDates() async {
    final readings = await loadFromJson();
    return readings.keys.toList()..sort();
  }

  /// Kiểm tra ngày có bài đọc không
  static Future<bool> hasReadingForDate(DateTime date) async {
    final readings = await loadFromJson();
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return readings.containsKey(dateKey) &&
        readings[dateKey]!.readings.isNotEmpty;
  }

  /// Clear cache (dùng khi cần reload dữ liệu)
  static void clearCache() {
    _cachedReadings = null;
  }
}
