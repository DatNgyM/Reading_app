import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BiblePdfService {
  // Map Cựu Ước - CẬP NHẬT CHÍNH XÁC VÀ ĐẦY ĐỦ
  static final Map<String, BibleBookInfo> _oldTestamentBooks = {
    'St': BibleBookInfo('Sáng Thế Ký', 'eBookKinhThanhCuuUoc.pdf', 1, 50),
    'Xh': BibleBookInfo('Xuất Hành', 'eBookKinhThanhCuuUoc.pdf', 100, 40),
    'Lv': BibleBookInfo('Lê-vi Ký', 'eBookKinhThanhCuuUoc.pdf', 180, 27),
    'Ds': BibleBookInfo('Dân Số Ký', 'eBookKinhThanhCuuUoc.pdf', 234, 36),
    'Đnl': BibleBookInfo('Phục Truyền', 'eBookKinhThanhCuuUoc.pdf', 306, 34),
    'Gs': BibleBookInfo('Giô-suê', 'eBookKinhThanhCuuUoc.pdf', 340, 24),
    'Tl': BibleBookInfo('Thủ Lãnh', 'eBookKinhThanhCuuUoc.pdf', 388, 21),
    'R': BibleBookInfo('Rút', 'eBookKinhThanhCuuUoc.pdf', 430, 4),
    '1 Sm': BibleBookInfo('1 Sa-mu-en', 'eBookKinhThanhCuuUoc.pdf', 438, 31),
    '2 Sm': BibleBookInfo('2 Sa-mu-en', 'eBookKinhThanhCuuUoc.pdf', 500, 24),
    '1 V': BibleBookInfo('1 Các Vua', 'eBookKinhThanhCuuUoc.pdf', 548, 22),
    '2 V': BibleBookInfo('2 Các Vua', 'eBookKinhThanhCuuUoc.pdf', 592, 25),
    '1 Sb':
        BibleBookInfo('1 Sử Biên Niên', 'eBookKinhThanhCuuUoc.pdf', 640, 29),
    '2 Sb':
        BibleBookInfo('2 Sử Biên Niên', 'eBookKinhThanhCuuUoc.pdf', 698, 36),
    'Er': BibleBookInfo('E-xơ-ra', 'eBookKinhThanhCuuUoc.pdf', 754, 10),
    'Ne': BibleBookInfo('Nê-hê-mi', 'eBookKinhThanhCuuUoc.pdf', 774, 13),
    'Tb': BibleBookInfo('Tô-bi-a', 'eBookKinhThanhCuuUoc.pdf', 800, 14),
    'Gt': BibleBookInfo('Giu-đi-tha', 'eBookKinhThanhCuuUoc.pdf', 828, 16),
    'Et': BibleBookInfo('Ét-te', 'eBookKinhThanhCuuUoc.pdf', 860, 10),
    '1 Mc': BibleBookInfo('1 Ma-ca-bê', 'eBookKinhThanhCuuUoc.pdf', 880, 16),
    '2 Mc': BibleBookInfo('2 Ma-ca-bê', 'eBookKinhThanhCuuUoc.pdf', 912, 15),
    'G': BibleBookInfo('Gióp', 'eBookKinhThanhCuuUoc.pdf', 942, 42),
    'Tv': BibleBookInfo('Thi Thiên', 'eBookKinhThanhCuuUoc.pdf', 1026, 150),
    'Cn': BibleBookInfo('Châm Ngôn', 'eBookKinhThanhCuuUoc.pdf', 1176, 31),
    'Gv': BibleBookInfo('Giảng Viên', 'eBookKinhThanhCuuUoc.pdf', 1238, 12),
    'Dc': BibleBookInfo('Diễm Ca', 'eBookKinhThanhCuuUoc.pdf', 1262, 8),
    'Kn': BibleBookInfo('Khôn Ngoan', 'eBookKinhThanhCuuUoc.pdf', 1278, 19),
    'Hc': BibleBookInfo('Huấn Ca', 'eBookKinhThanhCuuUoc.pdf', 1316, 51),
    'Is': BibleBookInfo('Ê-sai', 'eBookKinhThanhCuuUoc.pdf', 1368, 66),
    'Gr': BibleBookInfo('Giê-rê-mi', 'eBookKinhThanhCuuUoc.pdf', 1500, 52),
    'Ac': BibleBookInfo('Ai Ca', 'eBookKinhThanhCuuUoc.pdf', 1604, 5),
    'Br': BibleBookInfo('Ba-rúc', 'eBookKinhThanhCuuUoc.pdf', 1614, 6),
    'Ed': BibleBookInfo('Ê-dê-ki-en', 'eBookKinhThanhCuuUoc.pdf', 1630, 48),
    'Đn': BibleBookInfo('Đa-ni-en', 'eBookKinhThanhCuuUoc.pdf', 1726, 14),
    'Hs': BibleBookInfo('Hô-sê', 'eBookKinhThanhCuuUoc.pdf', 1754, 14),
    'Ge': BibleBookInfo('Giô-en', 'eBookKinhThanhCuuUoc.pdf', 1782, 3),
    'Am': BibleBookInfo('A-mốt', 'eBookKinhThanhCuuUoc.pdf', 1788, 9),
    'Ob': BibleBookInfo('Áp-đi-a', 'eBookKinhThanhCuuUoc.pdf', 1806, 1),
    'Gn': BibleBookInfo('Giô-na', 'eBookKinhThanhCuuUoc.pdf', 1808, 4),
    'Mk': BibleBookInfo('Mi-kha', 'eBookKinhThanhCuuUoc.pdf', 1816, 7),
    'Nk': BibleBookInfo('Na-khum', 'eBookKinhThanhCuuUoc.pdf', 1830, 3),
    'Kb': BibleBookInfo('Kha-ba-cúc', 'eBookKinhThanhCuuUoc.pdf', 1836, 3),
    'Xp': BibleBookInfo('Xô-phô-ni-a', 'eBookKinhThanhCuuUoc.pdf', 1842, 3),
    'Hg': BibleBookInfo('Khác-gai', 'eBookKinhThanhCuuUoc.pdf', 1848, 2),
    'Dcr': BibleBookInfo('Da-ca-ri-a', 'eBookKinhThanhCuuUoc.pdf', 1852, 14),
    'Ml': BibleBookInfo('Ma-la-khi', 'eBookKinhThanhCuuUoc.pdf', 1880, 4),
  };

  // Map Tân Ước - CẬP NHẬT CHÍNH XÁC VÀ ĐẦY ĐỦ
  static final Map<String, BibleBookInfo> _newTestamentBooks = {
    'Mt': BibleBookInfo('Ma-thi-ơ', 'eBookKinhThanhTanUoc.pdf', 1, 28),
    'Mc': BibleBookInfo('Mác', 'eBookKinhThanhTanUoc.pdf', 57, 16),
    'Lc': BibleBookInfo('Lu-ca', 'eBookKinhThanhTanUoc.pdf', 113, 24),
    'Ga': BibleBookInfo('Giăng', 'eBookKinhThanhTanUoc.pdf', 137, 21),
    'Cv': BibleBookInfo('Công Vụ', 'eBookKinhThanhTanUoc.pdf', 200, 28),
    'Rm': BibleBookInfo('Rô-ma', 'eBookKinhThanhTanUoc.pdf', 271, 16),
    '1 Cr': BibleBookInfo('1 Cô-rinh-tô', 'eBookKinhThanhTanUoc.pdf', 288, 16),
    '2 Cr': BibleBookInfo('2 Cô-rinh-tô', 'eBookKinhThanhTanUoc.pdf', 320, 13),
    'Gl': BibleBookInfo('Ga-la-ti', 'eBookKinhThanhTanUoc.pdf', 346, 6),
    'Ep': BibleBookInfo('Ê-phê-sô', 'eBookKinhThanhTanUoc.pdf', 358, 6),
    'Pl': BibleBookInfo('Phi-líp', 'eBookKinhThanhTanUoc.pdf', 370, 4),
    'Cl': BibleBookInfo('Cô-lô-se', 'eBookKinhThanhTanUoc.pdf', 378, 4),
    '1 Tx':
        BibleBookInfo('1 Tê-sa-lô-ni-ca', 'eBookKinhThanhTanUoc.pdf', 386, 5),
    '2 Tx':
        BibleBookInfo('2 Tê-sa-lô-ni-ca', 'eBookKinhThanhTanUoc.pdf', 396, 3),
    '1 Tm': BibleBookInfo('1 Ti-mô-thê', 'eBookKinhThanhTanUoc.pdf', 402, 6),
    '2 Tm': BibleBookInfo('2 Ti-mô-thê', 'eBookKinhThanhTanUoc.pdf', 414, 4),
    'Tt': BibleBookInfo('Tít', 'eBookKinhThanhTanUoc.pdf', 422, 3),
    'Plm': BibleBookInfo('Phi-lê-môn', 'eBookKinhThanhTanUoc.pdf', 428, 1),
    'Dt': BibleBookInfo('Hê-bơ-rơ', 'eBookKinhThanhTanUoc.pdf', 430, 13),
    'Gc': BibleBookInfo('Gia-cơ', 'eBookKinhThanhTanUoc.pdf', 456, 5),
    '1 Pr': BibleBookInfo('1 Phi-e-rơ', 'eBookKinhThanhTanUoc.pdf', 466, 5),
    '2 Pr': BibleBookInfo('2 Phi-e-rơ', 'eBookKinhThanhTanUoc.pdf', 476, 3),
    '1 Ga': BibleBookInfo('1 Giăng', 'eBookKinhThanhTanUoc.pdf', 482, 5),
    '2 Ga': BibleBookInfo('2 Giăng', 'eBookKinhThanhTanUoc.pdf', 492, 1),
    '3 Ga': BibleBookInfo('3 Giăng', 'eBookKinhThanhTanUoc.pdf', 494, 1),
    'Gđ': BibleBookInfo('Giu-đe', 'eBookKinhThanhTanUoc.pdf', 496, 1),
    'Kh': BibleBookInfo('Khải Huyền', 'eBookKinhThanhTanUoc.pdf', 498, 22),
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
      // Nếu chỉ có số chương đơn giản
      try {
        chapter = int.parse(cleanChapters);
      } catch (e) {
        chapter = 1; // fallback
      }
    }

    // Tìm sách với logic tìm kiếm cải tiến
    final allBooks = {..._oldTestamentBooks, ..._newTestamentBooks};
    BibleBookInfo? bookInfo;

    // Tìm kiếm chính xác trước
    bookInfo = allBooks[book.trim()];

    // Nếu không tìm thấy, thử tìm kiếm không phân biệt hoa thường
    if (bookInfo == null) {
      for (var entry in allBooks.entries) {
        if (book.trim().toLowerCase() == entry.key.toLowerCase()) {
          bookInfo = entry.value;
          break;
        }
      }
    }

    // Nếu vẫn không tìm thấy, thử tìm kiếm theo tên đầy đủ
    if (bookInfo == null) {
      for (var entry in allBooks.entries) {
        if (entry.value.fullName
                .toLowerCase()
                .contains(book.trim().toLowerCase()) ||
            book
                .trim()
                .toLowerCase()
                .contains(entry.value.fullName.toLowerCase())) {
          bookInfo = entry.value;
          break;
        }
      }
    }

    if (bookInfo != null) {
      // Sử dụng mapping chính xác cho từng chương cụ thể
      Map<String, Map<int, int>> chapterPageMap = {
        'Lc': {
          1: 89,
          2: 91,
          3: 93,
          4: 95,
          5: 97,
          6: 99,
          7: 101,
          8: 103,
          9: 105,
          10: 107,
          11: 109,
          12: 111,
          13: 125,
          14: 127,
          15: 129,
          16: 131,
          17: 133,
          18: 135,
          19: 137,
          20: 139,
          21: 141,
          22: 143,
          23: 145,
          24: 147
        },
        'Rm': {
          1: 257,
          2: 259,
          3: 261,
          4: 263,
          5: 265,
          6: 267,
          7: 269,
          8: 271,
          9: 273,
          10: 275,
          11: 277,
          12: 279,
          13: 281,
          14: 283,
          15: 285,
          16: 287
        },
        'Mt': {
          1: 1,
          2: 3,
          3: 5,
          4: 7,
          5: 9,
          6: 11,
          7: 13,
          8: 15,
          9: 17,
          10: 19,
          11: 21,
          12: 23,
          13: 25,
          14: 27,
          15: 29,
          16: 31,
          17: 33,
          18: 35,
          19: 37,
          20: 39,
          21: 41,
          22: 43,
          23: 45,
          24: 47,
          25: 49,
          26: 51,
          27: 53,
          28: 55
        },
        'Mc': {
          1: 57,
          2: 59,
          3: 61,
          4: 63,
          5: 65,
          6: 67,
          7: 69,
          8: 71,
          9: 73,
          10: 75,
          11: 77,
          12: 79,
          13: 81,
          14: 83,
          15: 85,
          16: 87
        },
        'Ga': {
          1: 137,
          2: 139,
          3: 141,
          4: 143,
          5: 145,
          6: 147,
          7: 149,
          8: 151,
          9: 153,
          10: 155,
          11: 157,
          12: 159,
          13: 161,
          14: 163,
          15: 165,
          16: 167,
          17: 169,
          18: 171,
          19: 173,
          20: 175,
          21: 177
        },
        'Cv': {
          1: 201,
          2: 203,
          3: 205,
          4: 207,
          5: 209,
          6: 211,
          7: 213,
          8: 215,
          9: 217,
          10: 219,
          11: 221,
          12: 223,
          13: 225,
          14: 227,
          15: 229,
          16: 231,
          17: 233,
          18: 235,
          19: 237,
          20: 239,
          21: 241,
          22: 243,
          23: 245,
          24: 247,
          25: 249,
          26: 251,
          27: 253,
          28: 255
        },
        'Gl': {1: 347, 2: 349, 3: 351, 4: 353, 5: 355, 6: 357},
        'Ep': {1: 359, 2: 361, 3: 363, 4: 365, 5: 367, 6: 369},
        'Pl': {1: 371, 2: 373, 3: 375, 4: 377},
        'Cl': {1: 379, 2: 381, 3: 383, 4: 385}
      };

      // Kiểm tra mapping cụ thể trước
      if (chapterPageMap.containsKey(book) &&
          chapterPageMap[book]!.containsKey(chapter)) {
        int exactPage = chapterPageMap[book]![chapter]!;
        print('Book: $book, Chapter: $chapter, ExactPage: $exactPage');
        return exactPage;
      }

      // Fallback về công thức cũ nếu không có mapping
      int pagesPerChapter = 2;
      if (bookInfo.fullName.contains('Thi Thiên') ||
          bookInfo.fullName.contains('Châm Ngôn') ||
          bookInfo.fullName.contains('Rút') ||
          bookInfo.fullName.contains('Áp-đi-a') ||
          bookInfo.fullName.contains('Phi-lê-môn') ||
          bookInfo.fullName.contains('2 Giăng') ||
          bookInfo.fullName.contains('3 Giăng') ||
          bookInfo.fullName.contains('Giu-đe')) {
        pagesPerChapter = 1;
      } else if (bookInfo.fullName.contains('Ê-sai') ||
          bookInfo.fullName.contains('Giê-rê-mi') ||
          bookInfo.fullName.contains('Ê-dê-ki-en') ||
          bookInfo.fullName.contains('Thi Thiên') ||
          bookInfo.fullName.contains('Khải Huyền')) {
        pagesPerChapter = 3;
      }

      int calculatedPage = bookInfo.startPage + (chapter - 1) * pagesPerChapter;
      print(
          'Book: $book, Chapter: $chapter, StartPage: ${bookInfo.startPage}, PagesPerChapter: $pagesPerChapter, CalculatedPage: $calculatedPage');
      return calculatedPage;
    }

    print('Warning: Book "$book" not found, returning page 0');
    return 0;
  }

  static String getPdfFile(String book) {
    // Tìm kiếm trong cả Cựu Ước và Tân Ước
    final allBooks = {..._oldTestamentBooks, ..._newTestamentBooks};

    // Tìm kiếm chính xác trước
    BibleBookInfo? bookInfo = allBooks[book.trim()];

    // Nếu không tìm thấy, thử tìm kiếm không phân biệt hoa thường
    if (bookInfo == null) {
      for (var entry in allBooks.entries) {
        if (book.trim().toLowerCase() == entry.key.toLowerCase()) {
          bookInfo = entry.value;
          break;
        }
      }
    }

    // Nếu vẫn không tìm thấy, thử tìm kiếm theo tên đầy đủ
    if (bookInfo == null) {
      for (var entry in allBooks.entries) {
        if (entry.value.fullName
                .toLowerCase()
                .contains(book.trim().toLowerCase()) ||
            book
                .trim()
                .toLowerCase()
                .contains(entry.value.fullName.toLowerCase())) {
          bookInfo = entry.value;
          break;
        }
      }
    }

    if (bookInfo != null) {
      return bookInfo.pdfFile;
    }

    // Fallback về Cựu Ước nếu không tìm thấy
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
