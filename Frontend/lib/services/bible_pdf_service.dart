import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BiblePdfService {
  // Map Cựu Ước - CẬP NHẬT CHÍNH XÁC
  static final Map<String, BibleBookInfo> _oldTestamentBooks = {
    'St': BibleBookInfo('Sáng Thế Ký', 'eBookKinhThanhCuuUoc.pdf', 15, 50),
    'Xh': BibleBookInfo('Xuất Hành', 'eBookKinhThanhCuuUoc.pdf', 90, 40),
    'Lv': BibleBookInfo('Lê-vi Ký', 'eBookKinhThanhCuuUoc.pdf', 150, 27),
    'Ds': BibleBookInfo('Dân Số Ký', 'eBookKinhThanhCuuUoc.pdf', 190, 36),
    'Đnl': BibleBookInfo('Phục Truyền', 'eBookKinhThanhCuuUoc.pdf', 240, 34),
    'Tv': BibleBookInfo('Thi Thiên', 'eBookKinhThanhCuuUoc.pdf', 500, 150),
    'Cn': BibleBookInfo('Châm Ngôn', 'eBookKinhThanhCuuUoc.pdf', 700, 31),
    'Hc': BibleBookInfo('Huấn Ca', 'eBookKinhThanhCuuUoc.pdf', 800, 51),
    'Is': BibleBookInfo('Ê-sai', 'eBookKinhThanhCuuUoc.pdf', 600, 66),
  };

  // Map Tân Ước - CẬP NHẬT CHÍNH XÁC
  static final Map<String, BibleBookInfo> _newTestamentBooks = {
    'Mt': BibleBookInfo('Ma-thi-ơ', 'eBookKinhThanhTanUoc.pdf', 70, 28),
    'Mc': BibleBookInfo('Mác', 'eBookKinhThanhTanUoc.pdf', 120, 16),
    'Lc': BibleBookInfo('Lu-ca', 'eBookKinhThanhTanUoc.pdf', 150, 24),
    'Ga': BibleBookInfo('Giăng', 'eBookKinhThanhTanUoc.pdf', 200, 21),
    '1 Ga': BibleBookInfo('1 Giăng', 'eBookKinhThanhTanUoc.pdf', 550, 5),
    '2 Ga': BibleBookInfo('2 Giăng', 'eBookKinhThanhTanUoc.pdf', 560, 1),
    '3 Ga': BibleBookInfo('3 Giăng', 'eBookKinhThanhTanUoc.pdf', 562, 1),
    'Cv': BibleBookInfo('Công Vụ', 'eBookKinhThanhTanUoc.pdf', 240, 28),
    'Rm': BibleBookInfo('Rô-ma', 'eBookKinhThanhTanUoc.pdf', 300, 16),
    'Gl': BibleBookInfo('Ga-la-ti', 'eBookKinhThanhTanUoc.pdf', 385, 6),
    'Ep': BibleBookInfo('Ê-phê-sô', 'eBookKinhThanhTanUoc.pdf', 395, 6),
  };

  static Map<String, BibleBookInfo> getOldTestamentBooks() =>
      _oldTestamentBooks;
  static Map<String, BibleBookInfo> getNewTestamentBooks() =>
      _newTestamentBooks;

  static Future<String> copyPdfToLocal(String pdfFileName) async {
    final ByteData data = await rootBundle.load('assets/pdfs/$pdfFileName');
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/$pdfFileName');
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    return tempFile.path;
  }

  static int getPageNumber(String book, String chapters) {
    // Parse chapter từ "35:12-14" -> 35
    int chapter = 1;
    if (chapters.contains(':')) {
      chapter = int.parse(chapters.split(':')[0]);
    } else if (chapters.contains('-')) {
      final parts = chapters.split('-');
      if (parts[0].contains(':')) {
        chapter = int.parse(parts[0].split(':')[0]);
      } else {
        chapter = int.parse(parts[0]);
      }
    }

    // Tìm sách
    final allBooks = {..._oldTestamentBooks, ..._newTestamentBooks};
    BibleBookInfo? bookInfo;

    for (var entry in allBooks.entries) {
      if (book.trim() == entry.key ||
          book.trim().toLowerCase() == entry.key.toLowerCase()) {
        bookInfo = entry.value;
        break;
      }
    }

    if (bookInfo != null) {
      // Mỗi chương ~ 2 trang
      return bookInfo.startPage + (chapter - 1) * 2;
    }

    print('Warning: Book "$book" not found, returning page 0');
    return 0;
  }

  static String getPdfFile(String book) {
    for (var entry in _newTestamentBooks.entries) {
      if (book.trim() == entry.key) {
        return entry.value.pdfFile;
      }
    }
    return 'eBookKinhThanhCuuUoc.pdf';
  }
}

class BibleBookInfo {
  final String fullName;
  final String pdfFile;
  final int startPage;
  final int totalChapters;

  BibleBookInfo(
      this.fullName, this.pdfFile, this.startPage, this.totalChapters);
}
