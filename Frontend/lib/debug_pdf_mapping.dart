import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 KIỂM TRA MAPPING PDF CHI TIẾT');
  print('═' * 50);
  
  try {
    // Load JSON data
    final String jsonString = await rootBundle.loadString('assets/data/lich_cong_giao_2025.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    
    // Test các trường hợp cụ thể mà user báo lỗi
    final testCases = [
      {'date': '2025-10-25', 'description': 'Hôm nay - Cp Antôniô Galvão'},
      {'date': '2025-01-01', 'description': 'Ngày 1/1 - TẾT ÂT TỴ'},
    ];
    
    for (var testCase in testCases) {
      final date = testCase['date'] as String;
      final description = testCase['description'] as String;
      
      if (jsonData.containsKey(date)) {
        final dayData = jsonData[date];
        print('\n📅 $description ($date):');
        print('🎭 ${dayData['saintName']}');
        
        final readings = dayData['readings'] as List<dynamic>;
        for (var reading in readings) {
          final book = reading['book'] as String;
          final chapters = reading['chapters'] as String;
          final type = reading['type'] as String;
          
          // Tính toán trang PDF
          final pageNumber = _calculatePageNumber(book, chapters);
          
          print('📚 $type: $book $chapters');
          print('   📄 File: ${reading['pdfFile']}');
          print('   📖 Trang PDF: $pageNumber');
          print('   ⚠️  CẦN KIỂM TRA: Trang $pageNumber có đúng nội dung $book $chapters không?');
        }
      }
    }
    
    // Test thêm một số trường hợp khác
    print('\n🔍 TEST THÊM CÁC TRƯỜNG HỢP KHÁC:');
    final additionalTests = [
      {'book': 'Lc', 'chapters': '13:1-9', 'expected': 'Lc 13:1-9'},
      {'book': 'Rm', 'chapters': '8:1-11', 'expected': 'Rm 8:1-11'},
      {'book': 'Mt', 'chapters': '2:1-12', 'expected': 'Mt 2:1-12'},
      {'book': 'Ga', 'chapters': '2:1-11', 'expected': 'Ga 2:1-11'},
    ];
    
    for (var test in additionalTests) {
      final book = test['book'] as String;
      final chapters = test['chapters'] as String;
      final expected = test['expected'] as String;
      final pageNumber = _calculatePageNumber(book, chapters);
      
      print('📖 $expected → Trang $pageNumber');
    }
    
  } catch (e) {
    print('❌ Lỗi: $e');
  }
  
  print('\n═' * 50);
  print('✅ HOÀN THÀNH KIỂM TRA!');
  print('💡 Hãy kiểm tra thủ công các trang PDF để xác nhận nội dung');
}

int _calculatePageNumber(String book, String chapters) {
  // Parse chapter từ "35:12-14" hoặc "(35:12-14)" -> 35
  int chapter = 1;

  // Loại bỏ dấu ngoặc đơn nếu có
  String cleanChapters = chapters.replaceAll(RegExp(r'[()]'), '').trim();

  if (cleanChapters.contains(':')) {
    chapter = int.parse(cleanChapters.split(':')[0]);
  } else if (cleanChapters.contains('-')) {
    final parts = cleanChapters.split('-');
    if (parts[0].contains(':')) {
      chapter = int.parse(parts[0].split(':')[0]);
    } else {
      chapter = int.parse(parts[0]);
    }
  } else {
    try {
      chapter = int.parse(cleanChapters);
    } catch (e) {
      chapter = 1;
    }
  }

  // Mapping chính xác cho từng chương cụ thể
  Map<String, Map<int, int>> chapterPageMap = {
    'Lc': {
      1: 89, 2: 91, 3: 93, 4: 95, 5: 97, 6: 99, 7: 101, 8: 103, 9: 105, 10: 107,
      11: 109, 12: 111, 13: 125, 14: 127, 15: 129, 16: 131, 17: 133, 18: 135, 19: 137, 20: 139,
      21: 141, 22: 143, 23: 145, 24: 147
    },
    'Rm': {
      1: 257, 2: 259, 3: 261, 4: 263, 5: 265, 6: 267, 7: 269, 8: 271, 9: 273, 10: 275,
      11: 277, 12: 279, 13: 281, 14: 283, 15: 285, 16: 287
    },
    'Mt': {
      1: 1, 2: 3, 3: 5, 4: 7, 5: 9, 6: 11, 7: 13, 8: 15, 9: 17, 10: 19,
      11: 21, 12: 23, 13: 25, 14: 27, 15: 29, 16: 31, 17: 33, 18: 35, 19: 37, 20: 39,
      21: 41, 22: 43, 23: 45, 24: 47, 25: 49, 26: 51, 27: 53, 28: 55
    },
    'Ga': {
      1: 137, 2: 139, 3: 141, 4: 143, 5: 145, 6: 147, 7: 149, 8: 151, 9: 153, 10: 155,
      11: 157, 12: 159, 13: 161, 14: 163, 15: 165, 16: 167, 17: 169, 18: 171, 19: 173, 20: 175, 21: 177
    },
  };

  // Kiểm tra mapping cụ thể trước
  if (chapterPageMap.containsKey(book) && chapterPageMap[book]!.containsKey(chapter)) {
    return chapterPageMap[book]![chapter]!;
  }

  // Fallback
  return 0;
}
