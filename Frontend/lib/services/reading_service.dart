import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/reading_content.dart';

class ReadingService {
  Map<String, dynamic>? _lichCongGiao;
  Map<String, dynamic>? _cuuUoc;
  Map<String, dynamic>? _tanUoc;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final lichJson =
        await rootBundle.loadString('assets/data/lich_cong_giao_2025.json');
    final cuuJson = await rootBundle.loadString('assets/data/Cuu_uoc.json');
    final tanJson = await rootBundle.loadString('assets/data/Tan_uoc.json');

    _lichCongGiao = json.decode(lichJson) as Map<String, dynamic>?;
    _cuuUoc = json.decode(cuuJson) as Map<String, dynamic>?;
    _tanUoc = json.decode(tanJson) as Map<String, dynamic>?;
    _initialized = true;
  }

  Future<List<ReadingContent>> getDailyReadingsForDate(String date,
      {bool skipPsalmsAndResponsorial = true}) async {
    await init();
    final dayData = _lichCongGiao?[date];
    if (dayData == null) return [];

    final readingsList = (dayData['readings'] as List<dynamic>?) ?? [];
    final List<ReadingContent> out = [];

    for (var r in readingsList) {
      final type = r['type'] as String? ?? '';
      final book = r['book'] as String?;
      final chapters = r['chapters'] as String?;

      if (skipPsalmsAndResponsorial) {
        final low = type.toLowerCase();
        if (low.contains('thi') ||
            low.contains('đáp') ||
            low.contains('vịnh') ||
            (book?.toLowerCase().contains('tv') ?? false) ||
            (book?.toLowerCase().contains('thánh vịnh') ?? false)) {
          continue;
        }
      }

      if (book != null && chapters != null) {
        final content = _getReadingContent(book, chapters);
        if (content != null) {
          out.add(ReadingContent(
              type: type, book: book, chapters: chapters, content: content));
        }
      }
    }

    return out;
  }

  Future<String?> lookupPassage(
      String bookRaw, int chapter, int startVerse, int endVerse) async {
    await init();
    final bookKey = _mapBookName(bookRaw);
    Map<String, dynamic>? bookData = _tanUoc?[bookKey] ?? _cuuUoc?[bookKey];

    if (bookData == null) {
      // try a few fallbacks
      final alt = _normalize(bookKey);
      bookData = _tanUoc?[alt] ?? _cuuUoc?[alt];
    }

    if (bookData == null) {
      return 'Không tìm thấy sách "$bookRaw" trong dữ liệu.';
    }

    final chapterData = bookData['$chapter'] as Map<String, dynamic>?;
    if (chapterData == null) {
      return 'Không tìm thấy chương $chapter trong sách $bookKey.';
    }

    final buffer = StringBuffer();
    for (int v = startVerse; v <= endVerse; v++) {
      final verseText = chapterData['$v'];
      if (verseText != null) {
        buffer.writeln('$v. $verseText\n');
      } else {
        buffer.writeln('$v. [Không tìm thấy câu $v]\n');
      }
    }
    return buffer.toString();
  }

  // -------------------------
  // Internal parsing + mapping
  // -------------------------

  String? _getReadingContent(String book, String chaptersRange) {
    final bookKey = _mapBookName(book);

    Map<String, dynamic>? bookData = _cuuUoc?[bookKey] ?? _tanUoc?[bookKey];

    if (bookData == null) {
      final alt = _normalize(bookKey);
      bookData = _cuuUoc?[alt] ?? _tanUoc?[alt];
    }
    if (bookData == null) return null;

    final parts = chaptersRange.split(',');
    Map<String, List<String>> chapterRanges = {};
    String? currentChapter;

    for (var part in parts) {
      part = part.trim();
      if (part.contains(':')) {
        final chapterPart = part.split(':')[0];
        currentChapter = chapterPart;
        chapterRanges
            .putIfAbsent(currentChapter, () => [])
            .add(part.split(':')[1]);
      } else if (currentChapter != null) {
        chapterRanges[currentChapter]!.add(part);
      }
    }

    final sb = StringBuffer();
    for (var entry in chapterRanges.entries) {
      final chapter = entry.key;
      final ranges = entry.value;
      final chapterData = bookData[chapter];
      if (chapterData == null) continue;
      for (var range in ranges) {
        if (range.contains('-')) {
          final rp = range.split('-');
          final s = _safeParseInt(rp[0]);
          final e = _safeParseInt(rp[1]);
          if (s == null || e == null) continue;
          sb.writeln('\n$bookKey $chapter:$s-$e\n');
          for (int i = s; i <= e; i++) {
            final verse = chapterData[i.toString()];
            if (verse != null) sb.writeln('$i. $verse\n');
          }
        } else {
          final v = _safeParseInt(range);
          if (v == null) continue;
          final verseText = chapterData[v.toString()];
          sb.writeln('\n$bookKey $chapter:$v\n');
          if (verseText != null) sb.writeln('$v. $verseText\n');
        }
      }
    }
    return sb.toString();
  }

  int? _safeParseInt(String value) {
    try {
      final cleaned = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) return null;
      return int.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  String _normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[\s\.\-_,]'), '');
  }

  String _mapBookName(String raw) {
    final k = _normalize(raw);

    final Map<String, String> map = {
      'st': 'Sáng Thế Ký', 'stk': 'Sáng Thế Ký', 'sáng thế ký': 'Sáng Thế Ký',
      'sáng thế': 'Sáng Thế Ký',
      'xh': 'Xuất Hành', 'xuất hành': 'Xuất Hành',
      'lv': 'Lê-vi', 'lê-vi': 'Lê-vi',
      'ds': 'Dân Số', 'dân số': 'Dân Số',
      'dnl': 'Đệ Nhị Luật', 'đệ nhị luật': 'Đệ Nhị Luật',

      // Sách lịch sử
      'tl': 'Thủ Lãnh', 'thủ lãnh': 'Thủ Lãnh',
      'ru': 'Rút', 'rút': 'Rút',
      '1sm': 'Samuen 1', '2sm': 'Samuen 2', 'samuen': 'Samuen 1',
      'samuel': 'Samuen 1',
      '1vua': 'Vua 1', '2vua': 'Vua 2',
      '1sb': 'Sử Biên 1', '2sb': 'Sử Biên 2',

      // Một số sách khác CT
      'ezr': 'Étra', 'neh': 'NơKhemia', 'tb': 'Tôbia',

      // Thơ ca / Khôn ngoan
      'ps': 'Thánh Vịnh', 'tv': 'Thánh Vịnh', 'thánh vịnh': 'Thánh Vịnh',
      'cn': 'Châm Ngôn', 'châm ngôn': 'Châm Ngôn',
      'gv': 'Giảng Viên', 'giảng viên': 'Giảng Viên',
      'dt': 'Diễm Ca', 'diễm ca': 'Diễm Ca',
      'kn': 'Khôn Ngoan', 'hc': 'Huấn Ca',

      // Tiên tri (chọn tên gần nhất)
      'isa': 'I-sai-a', 'i-sai-a': 'I-sai-a', 'i sai a': 'I-sai-a',
      'jer': 'Giêrêmia', 'giêrêmia': 'Giêrêmia',
      'ezek': 'Êdêkien', 'ênêkien': 'Êdêkien', 'đanien': 'Đanien',
      'hosea': 'Hôsê', 'joel': 'Giôen', 'amos': 'A-mốt', 'obad': 'Ôvađia',
      'jonah': 'Giôna', 'mic': 'Mikha', 'nah': 'Nakhum', 'hab': 'Khabarúc',
      'zeph': 'Xôphônia', 'hag': 'Khácgai', 'zec': 'Dacaria', 'mal': 'Malakhi',

      // Phúc Âm / Tân Ước (viết tắt phổ biến)
      'mt': 'Mátthêu', 'mátthêu': 'Mátthêu', 'matthew': 'Mátthêu',
      'mc': 'Máccô', 'máccô': 'Máccô', 'mark': 'Máccô',
      'lc': 'Luca', 'luca': 'Luca', 'luke': 'Luca',
      'jn': 'Gioan', 'gioan': 'Gioan', 'john': 'Gioan',

      // Thư NT (viết tắt)
      'cv': 'Công vụ Tông đồ', 'acts': 'Công vụ Tông đồ',
      'rm': 'Thư Rôma', 'rôma': 'Thư Rôma', 'roma': 'Thư Rôma',
      '1cr': 'Thư Côrintô', '2cr': 'Thư Côrintô',
      'gl': 'Thư Galát', 'ep': 'Thư Êphêsô', 'eph': 'Thư Êphêsô',
      'pl': 'Thư Philípphê', 'cl': 'Thư Côlôxê',
      '1tx': 'Thư Thêxalônica 1', '2tx': 'Thư Thêxalônica 2',
      '1tm': 'Thư Timôthê 1', '2tm': 'Thư Timôthê 2',
      'tt': 'Thư Titô', 'plm': 'Thư Philêmon', 'dt_nt': 'Thư Do thái',
      'gc': 'Thư Giacôbê', '1pr': 'Thư Phêrô 1', '2pr': 'Thư Phêrô 2',
      '1ga': 'Thư Gioan 1', '2ga': 'Thư Gioan 2', '3ga': 'Thư Gioan 3',
      'gd': 'Thư Giuđa', 'kh': 'Khải Huyền',
    };

    if (map.containsKey(k)) return map[k]!;
    // fallback: trả về tên gốc đã trim nếu không tìm thấy mapping
    return raw.trim();
  }

  // Public: trả về nội dung cả chương (title/content) hoặc message khi không tìm thấy
  Future<Map<String, String>> getChapterContent(
      String bookRaw, int chapter) async {
    await init();
    final bookKey = _mapBookName(bookRaw);
    Map<String, dynamic>? bookData = _cuuUoc?[bookKey] ?? _tanUoc?[bookKey];
    if (bookData == null) {
      final alt = _normalize(bookKey);
      bookData = _cuuUoc?[alt] ?? _tanUoc?[alt];
    }

    final title = '$bookKey $chapter';
    if (bookData == null) {
      return {
        'title': title,
        'content': 'Không tìm thấy sách "$bookRaw" trong dữ liệu.'
      };
    }

    final chapterData = bookData['$chapter'] as Map<String, dynamic>?;
    if (chapterData == null) {
      return {
        'title': title,
        'content': 'Không tìm thấy chương $chapter trong sách $bookKey.'
      };
    }

    final verseKeys = chapterData.keys.toList()
      ..sort(
          (a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
    final buffer = StringBuffer();
    buffer.writeln('$bookKey $chapter\n');
    for (var vk in verseKeys) {
      final vt = chapterData[vk];
      buffer.writeln('$vk. ${vt ?? "[Không có nội dung]"}\n');
    }
    return {'title': title, 'content': buffer.toString()};
  }

  // Public: tìm sách phù hợp với query (trả về các key có trong JSON)
  Future<List<String>> searchBookKeys(String query) async {
    await init();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final Set<String> found = {};
    void checkMap(Map<String, dynamic>? m) {
      if (m == null) return;
      for (var key in m.keys) {
        final keyStr = key.toString();
        final mapped = _mapBookName(keyStr).toLowerCase();
        if (keyStr.toLowerCase().contains(q) || mapped.contains(q)) {
          found.add(keyStr);
        }
      }
    }

    checkMap(_cuuUoc);
    checkMap(_tanUoc);
    return found.toList();
  }

  Map<String, dynamic>? get rawLich => _lichCongGiao;
}
