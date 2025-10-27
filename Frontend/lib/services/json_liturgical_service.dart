import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/daily_reading.dart';

class JsonLiturgicalService {
  static Map<DateTime, DailyReading>? _cachedReadings;

  /// Đọc dữ liệu từ file JSON thay vì PDF
  static Future<Map<DateTime, DailyReading>> loadFromJson() async {
    if (_cachedReadings != null) return _cachedReadings!;

    Map<DateTime, DailyReading> readings = {};

    try {
      // Đọc file JSON
      final String jsonString = await rootBundle.loadString('assets/data/lich_cong_giao_2025.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Parse từng ngày
      for (String dateKey in jsonData.keys) {
        final dateData = jsonData[dateKey];
        final DateTime date = DateTime.parse(dateKey);
        
        final String saintName = dateData['saintName'] ?? 'Ngày thường';
        final List<dynamic> readingsData = dateData['readings'] ?? [];

        List<ReadingReference> readingsList = [];
        
        for (var readingData in readingsData) {
          final String type = readingData['type'] ?? '';
          final String book = readingData['book'] ?? '';
          final String chapters = readingData['chapters'] ?? '';
          final String pdfFile = readingData['pdfFile'] ?? 'eBookKinhThanhCuuUoc.pdf';

          readingsList.add(ReadingReference(
            type: type,
            book: book,
            chapters: chapters,
            pdfFile: pdfFile,
          ));
        }

        readings[date] = DailyReading(
          date: date,
          saintName: saintName,
          readings: readingsList,
        );
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
    final readings = await loadFromJson();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return readings[todayKey];
  }

  /// Lấy bài đọc theo ngày cụ thể
  static Future<DailyReading?> getReadingForDate(DateTime date) async {
    final readings = await loadFromJson();
    final dateKey = DateTime(date.year, date.month, date.day);

    return readings[dateKey];
  }

  /// Lấy bài đọc trong khoảng thời gian
  static Future<List<DailyReading>> getReadingsForRange(DateTime startDate, DateTime endDate) async {
    final readings = await loadFromJson();
    List<DailyReading> result = [];

    for (DateTime date = startDate; date.isBefore(endDate.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
      final dateKey = DateTime(date.year, date.month, date.day);
      final reading = readings[dateKey];
      if (reading != null) {
        result.add(reading);
      }
    }

    return result;
  }

  /// Lấy bài đọc theo tháng
  static Future<List<DailyReading>> getReadingsForMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Ngày cuối tháng
    
    return getReadingsForRange(startDate, endDate);
  }

  /// In ra bài đọc hôm nay
  static Future<void> printTodayReading() async {
    final todayReading = await getTodayReading();
    
    if (todayReading != null) {
      print('\n📖 BÀI ĐỌC HÔM NAY - ${DateFormat('dd/MM/yyyy').format(todayReading.date)}');
      print('🎭 ${todayReading.saintName}');
      print('─' * 50);
      
      for (var reading in todayReading.readings) {
        print('📚 ${reading.type}: ${reading.book} ${reading.chapters}');
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
    
    if (reading != null) {
      print('\n📖 BÀI ĐỌC NGÀY ${DateFormat('dd/MM/yyyy').format(reading.date)}');
      print('🎭 ${reading.saintName}');
      print('─' * 50);
      
      for (var readingItem in reading.readings) {
        print('📚 ${readingItem.type}: ${readingItem.book} ${readingItem.chapters}');
        print('   📄 File: ${readingItem.pdfFile}');
      }
      print('─' * 50);
    } else {
      print('❌ Không tìm thấy bài đọc cho ngày ${DateFormat('dd/MM/yyyy').format(date)}');
    }
  }

  /// In ra bài đọc trong tháng
  static Future<void> printReadingsForMonth(int year, int month) async {
    final readings = await getReadingsForMonth(year, month);
    
    print('\n📅 BÀI ĐỌC THÁNG ${month}/${year}');
    print('═' * 60);
    
    for (var reading in readings) {
      print('\n📖 ${DateFormat('dd/MM').format(reading.date)} - ${reading.saintName}');
      for (var readingItem in reading.readings) {
        print('   📚 ${readingItem.type}: ${readingItem.book} ${readingItem.chapters}');
      }
    }
    print('\n═' * 60);
  }

  /// Tìm kiếm bài đọc theo sách
  static Future<List<DailyReading>> searchByBook(String bookName) async {
    final readings = await loadFromJson();
    List<DailyReading> result = [];

    for (var reading in readings.values) {
      bool hasBook = reading.readings.any((r) => 
        r.book.toLowerCase().contains(bookName.toLowerCase()));
      
      if (hasBook) {
        result.add(reading);
      }
    }

    return result;
  }

  /// Thống kê số lượng bài đọc
  static Future<Map<String, int>> getReadingStats() async {
    final readings = await loadFromJson();
    Map<String, int> stats = {};

    for (var reading in readings.values) {
      for (var readingItem in reading.readings) {
        stats[readingItem.book] = (stats[readingItem.book] ?? 0) + 1;
      }
    }

    return stats;
  }
}
