import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  // Khởi tạo Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  print('📖 DEMO: ĐỌC FILE JSON VÀ MAPPING VỚI PDF');
  print('═' * 60);

  try {
    // Đọc file JSON
    final String jsonString =
        await rootBundle.loadString('assets/data/lich_cong_giao_2025.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    print('✅ Đã load ${jsonData.length} ngày từ JSON');

    // Lấy ngày hôm nay
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (jsonData.containsKey(todayKey)) {
      final todayData = jsonData[todayKey];
      print('\n📅 BÀI ĐỌC HÔM NAY ($todayKey):');
      print('🎭 ${todayData['saintName']}');

      final readings = todayData['readings'] as List<dynamic>;
      for (var reading in readings) {
        print(
            '📚 ${reading['type']}: ${reading['book']} ${reading['chapters']}');
        print('   📄 File: ${reading['pdfFile']}');
      }
    } else {
      print('❌ Không tìm thấy bài đọc cho hôm nay');
    }

    // Lấy ngày 1/1/2025
    final testDate = '2025-01-01';
    if (jsonData.containsKey(testDate)) {
      final testData = jsonData[testDate];
      print('\n📅 BÀI ĐỌC NGÀY 1/1/2025:');
      print('🎭 ${testData['saintName']}');

      final readings = testData['readings'] as List<dynamic>;
      for (var reading in readings) {
        print(
            '📚 ${reading['type']}: ${reading['book']} ${reading['chapters']}');
        print('   📄 File: ${reading['pdfFile']}');
      }
    }

    // Thống kê
    print('\n📊 THỐNG KÊ:');
    Map<String, int> stats = {};
    for (var dateData in jsonData.values) {
      final readings = dateData['readings'] as List<dynamic>;
      for (var reading in readings) {
        final book = reading['book'] as String;
        stats[book] = (stats[book] ?? 0) + 1;
      }
    }

    final sortedStats = Map.fromEntries(
        stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

    int count = 0;
    for (var entry in sortedStats.entries) {
      if (count < 10) {
        print('   ${entry.key}: ${entry.value} lần');
        count++;
      }
    }
  } catch (e) {
    print('❌ Lỗi: $e');
  }

  print('\n═' * 60);
  print('✅ HOÀN THÀNH!');
}
