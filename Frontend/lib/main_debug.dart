import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 KIỂM TRA MAPPING PDF');
  print('═' * 40);
  
  try {
    // Load JSON data
    final String jsonString = await rootBundle.loadString('assets/data/lich_cong_giao_2025.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    
    // Test hôm nay
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    if (jsonData.containsKey(todayKey)) {
      final dayData = jsonData[todayKey];
      print('\n📅 HÔM NAY ($todayKey):');
      print('🎭 ${dayData['saintName']}');
      
      final readings = dayData['readings'] as List<dynamic>;
      for (var reading in readings) {
        final book = reading['book'] as String;
        final chapters = reading['chapters'] as String;
        final pageNumber = _getPageNumber(book, chapters);
        
        print('📚 ${reading['type']}: $book $chapters');
        print('   📄 File: ${reading['pdfFile']}');
        print('   📖 Trang: $pageNumber');
        print('   ⚠️  KIỂM TRA: Trang $pageNumber có đúng nội dung $book $chapters?');
      }
    }
    
  } catch (e) {
    print('❌ Lỗi: $e');
  }
  
  print('\n═' * 40);
  print('✅ HOÀN THÀNH!');
}

int _getPageNumber(String book, String chapters) {
  int chapter = 1;
  String cleanChapters = chapters.replaceAll(RegExp(r'[()]'), '').trim();

  if (cleanChapters.contains(':')) {
    chapter = int.parse(cleanChapters.split(':')[0]);
  }

  Map<String, Map<int, int>> chapterPageMap = {
    'Lc': {13: 125, 2: 91, 1: 89},
    'Rm': {8: 271, 1: 257},
    'Mt': {2: 3, 1: 1},
    'Ga': {2: 139, 1: 137},
  };

  if (chapterPageMap.containsKey(book) && chapterPageMap[book]!.containsKey(chapter)) {
    return chapterPageMap[book]![chapter]!;
  }

  return 0;
}
