import '../services/reading_service.dart';
import '../services/json_liturgical_service.dart';

class SearchService {
  final ReadingService _readingService = ReadingService();

  // Patterns for verse lookup
  static final RegExp patternVerse = RegExp(
    r'^(.+?)\s+(\d+)\s*:\s*(\d+)(?:\s*-\s*(\d+))?$',
    caseSensitive: false,
  );

  static final RegExp patternVerseComma = RegExp(
    r'^(.+?)\s+(\d+)\s*,\s*(\d+)(?:\s*-\s*(\d+))?$',
    caseSensitive: false,
  );

  static final RegExp patternChapter = RegExp(
    r'^(.+?)\s+(\d+)$',
    caseSensitive: false,
  );

  // Parse query and return direct content if it's a verse/chapter reference
  Future<Map<String, String>?> parseDirectLookup(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;

    // Try verse lookup patterns
    Match? m = patternVerse.firstMatch(q) ?? patternVerseComma.firstMatch(q);

    if (m != null) {
      try {
        final bookRaw = m.group(1)!.trim();
        final chapter = int.parse(m.group(2)!);
        final startVerse = int.parse(m.group(3)!);
        final endVerse =
            m.group(4) != null ? int.parse(m.group(4)!) : startVerse;

        final content = await _readingService.lookupPassage(
          bookRaw,
          chapter,
          startVerse,
          endVerse,
        );

        return {
          'title':
              '$bookRaw $chapter:$startVerse${startVerse != endVerse ? '-$endVerse' : ''}',
          'content': content ?? 'Không tìm thấy nội dung.',
        };
      } catch (e) {
        print('Verse lookup error: $e');
        return null;
      }
    }

    // Try whole chapter lookup
    final mC = patternChapter.firstMatch(q);
    if (mC != null) {
      try {
        final bookRaw = mC.group(1)!.trim();
        final chapter = int.parse(mC.group(2)!);
        return await _readingService.getChapterContent(bookRaw, chapter);
      } catch (e) {
        print('Whole-chapter lookup error: $e');
        return null;
      }
    }

    return null;
  }

  // Search Bible books by query
  Future<List<Map<String, dynamic>>> searchBibleBooks(String query) async {
    final List<Map<String, dynamic>> results = [];
    final q = query.trim();
    if (q.isEmpty) return results;

    final keys = await _readingService.searchBookKeys(q);

    for (var bookKey in keys) {
      final chapter = await _readingService.getChapterContent(bookKey, 1);
      results.add({
        'title': bookKey,
        'subtitle': 'Sách Kinh Thánh',
        'type': 'Sách',
        'previewTitle': chapter['title'] ?? bookKey,
        'previewContent': chapter['content'] ?? 'Không có nội dung.',
      });
    }

    return results;
  }

  // Search daily readings by query
  Future<List<Map<String, dynamic>>> searchDailyReadings(String query) async {
    final List<Map<String, dynamic>> results = [];
    final queryLower = query.toLowerCase();

    try {
      final readings = await JsonLiturgicalService.loadFromJson();

      for (var entry in readings.entries) {
        final reading = entry.value;

        if (reading.saintName.toLowerCase().contains(queryLower) ||
            reading.readings.any((r) =>
                r.book.toLowerCase().contains(queryLower) ||
                r.fullReference.toLowerCase().contains(queryLower))) {
          results.add({
            'title': reading.saintName,
            'subtitle': reading.date,
            'type': 'Lịch đọc',
            'date': reading.date,
          });
        }
      }
    } catch (e) {
      print('Error searching readings: $e');
    }

    return results;
  }
}
