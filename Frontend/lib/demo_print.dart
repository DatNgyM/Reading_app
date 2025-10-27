import 'package:flutter/material.dart';
import 'package:reading_app/services/json_liturgical_service.dart';
import 'package:reading_app/services/bible_pdf_service.dart';

void main() async {
  // Khởi tạo Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  print('📖 DEMO: SỬ DỤNG FILE JSON MAPPING VỚI PDF');
  print('═' * 60);
  
  // 1. In bài đọc hôm nay
  print('\n1️⃣ BÀI ĐỌC HÔM NAY:');
  await JsonLiturgicalService.printTodayReading();
  
  // 2. In bài đọc ngày cụ thể
  print('\n2️⃣ BÀI ĐỌC NGÀY 1/1/2025:');
  await JsonLiturgicalService.printReadingForDate(DateTime(2025, 1, 1));
  
  // 3. In bài đọc tháng 1/2025
  print('\n3️⃣ BÀI ĐỌC THÁNG 1/2025 (5 ngày đầu):');
  final monthReadings = await JsonLiturgicalService.getReadingsForMonth(2025, 1);
  for (int i = 0; i < 5 && i < monthReadings.length; i++) {
    final reading = monthReadings[i];
    print('\n📅 ${reading.date.day}/${reading.date.month} - ${reading.saintName}');
    for (var readingItem in reading.readings) {
      print('   📚 ${readingItem.type}: ${readingItem.book} ${readingItem.chapters}');
    }
  }
  
  // 4. Tìm kiếm bài đọc theo sách
  print('\n4️⃣ TÌM KIẾM BÀI ĐỌC LU-CA (5 ngày đầu):');
  final lukeReadings = await JsonLiturgicalService.searchByBook('Lc');
  for (int i = 0; i < 5 && i < lukeReadings.length; i++) {
    final reading = lukeReadings[i];
    print('\n📅 ${reading.date.day}/${reading.date.month} - ${reading.saintName}');
    for (var readingItem in reading.readings) {
      if (readingItem.book == 'Lc') {
        print('   📚 ${readingItem.type}: ${readingItem.book} ${readingItem.chapters}');
      }
    }
  }
  
  // 5. Thống kê
  print('\n5️⃣ THỐNG KÊ BÀI ĐỌC:');
  final stats = await JsonLiturgicalService.getReadingStats();
  final sortedStats = Map.fromEntries(
    stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
  );
  
  int count = 0;
  for (var entry in sortedStats.entries) {
    if (count < 10) {
      print('   ${entry.key}: ${entry.value} lần');
      count++;
    }
  }
  
  // 6. Test mapping PDF
  print('\n6️⃣ TEST MAPPING PDF:');
  final testCases = [
    ('Lc', '2:16-21'),
    ('Rm', '8:1-11'),
    ('Gl', '4:4-7'),
    ('Mt', '2:1-12'),
    ('Ga', '2:1-11'),
  ];
  
  for (var testCase in testCases) {
    final book = testCase.$1;
    final chapters = testCase.$2;
    final pageNumber = BiblePdfService.getPageNumber(book, chapters);
    print('   📖 $book $chapters → Trang $pageNumber');
  }
  
  print('\n═' * 60);
  print('✅ HOÀN THÀNH DEMO!');
}
