import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../models/daily_reading.dart';

class LiturgicalCalendarService {
  static Map<DateTime, DailyReading>? _cachedReadings;

  static Future<Map<DateTime, DailyReading>> parseCalendarPdf() async {
    if (_cachedReadings != null) return _cachedReadings!;

    Map<DateTime, DailyReading> readings = {};

    try {
      final ByteData data =
          await rootBundle.load('assets/pdfs/lich-cong-giao-2025-all.pdf');
      final Uint8List bytes = data.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Đọc từng trang (mỗi trang = 1 tháng)
      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        String pageText = extractor.extractText(
            startPageIndex: pageIndex, endPageIndex: pageIndex);

        // Parse text của tháng
        _parseMonthPage(pageText, pageIndex + 1, readings);
      }

      document.dispose();
      _cachedReadings = readings;
    } catch (e) {
      print('Error parsing calendar PDF: $e');
    }

    return readings;
  }

  static void _parseMonthPage(
      String text, int month, Map<DateTime, DailyReading> readings) {
    List<String> lines = text.split('\n');

    int currentDay = 0;
    String currentSaint = '';
    List<String> currentReadings = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Tìm số ngày trong lịch (1-31)
      if (RegExp(r'^\d{1,2}$').hasMatch(line)) {
        // Lưu ngày trước đó
        if (currentDay > 0 && currentReadings.isNotEmpty) {
          _saveReading(
              2025, month, currentDay, currentSaint, currentReadings, readings);
        }

        // Reset cho ngày mới
        currentDay = int.parse(line);
        currentSaint = '';
        currentReadings = [];
      }
      // Tìm tên thánh
      else if (line.contains('Thánh') ||
          line.contains('Chúa') ||
          line.contains('Đức') ||
          line.contains('CP ') ||
          line.contains('Cn ') ||
          line.contains('CG ')) {
        currentSaint = line;
      }
      // Tìm bài đọc (dạng: "1 Ga 2:22-28" hoặc "Mc 1:14-20")
      else if (RegExp(r'[0-9]?\s*[A-Z][a-z]+\s+\d+').hasMatch(line)) {
        currentReadings.add(line);
      }
    }

    // Lưu ngày cuối cùng
    if (currentDay > 0 && currentReadings.isNotEmpty) {
      _saveReading(
          2025, month, currentDay, currentSaint, currentReadings, readings);
    }
  }

  static void _saveReading(
    int year,
    int month,
    int day,
    String saint,
    List<String> readingTexts,
    Map<DateTime, DailyReading> readings,
  ) {
    try {
      final date = DateTime(year, month, day);
      final List<ReadingReference> refs = [];

      int readingIndex = 1;
      for (String text in readingTexts) {
        // Parse "1 Ga 2:22-28" hoặc "Mc 1:14-20"
        RegExp pattern = RegExp(r'([0-9]?\s*[A-Z][a-z]+)\s+([\d:,\-\.;]+)');
        Match? match = pattern.firstMatch(text);

        if (match != null) {
          String book = match.group(1)!.trim();
          String chapters = match.group(2)!.trim();

          String type = 'Bài Đọc $readingIndex';
          if (text.contains('Tv') || text.contains('Thi')) {
            type = 'Thi Đáp';
          } else if (text.contains('Mc') ||
              text.contains('Mt') ||
              text.contains('Lc') ||
              text.contains('Ga')) {
            type = 'Tin Mừng';
          }

          // Xác định file PDF
          String pdfFile = _determinePdfFile(book);

          refs.add(ReadingReference(
            type: type,
            book: book,
            chapters: chapters,
            pdfFile: pdfFile,
          ));

          readingIndex++;
        }
      }

      readings[date] = DailyReading(
        date: date,
        saintName: saint.isEmpty ? 'Ngày thường' : saint,
        readings: refs,
      );
    } catch (e) {
      print('Error saving reading for $year-$month-$day: $e');
    }
  }

  static String _determinePdfFile(String book) {
    // Sách Tân Ước
    final newTestamentBooks = [
      'Mt', 'Mc', 'Lc', 'Ga', // Phúc Âm
      'Cv', 'Công', // Công Vụ
      'Rm', 'Rô', // Rô-ma
      'Cr', 'Cô', '1 Cr', '2 Cr', // Cô-rinh-tô
      'Gl', 'Ga', // Ga-la-ti
      'Ep', 'Êph', // Ê-phê-sô
      'Pl', 'Phi', // Phi-líp
      'Cl', 'Cô', // Cô-lô-se
      'Ts', 'Tê', '1 Ts', '2 Ts', // Tê-sa-lô-ni-ca
      'Tm', 'Ti', '1 Tm', '2 Tm', // Ti-mô-thê
      'Tt', 'Tít', // Tít
      'Plm', 'Phi', // Phi-lê-môn
      'Hr', 'Hê', // Hê-bơ-rơ
      'Gc', 'Gia', // Gia-cơ
      'Pr', 'Phierơ', '1 Pr', '2 Pr', // Phi-e-rơ
      'Ga', '1 Ga', '2 Ga', '3 Ga', // Thư Giăng
      'Gd', 'Giu', // Giu-đe
      'Kh', 'Khải', // Khải Huyền
    ];

    // Kiểm tra nếu là sách Tân Ước
    String bookCode = book.trim().split(' ').last;
    if (newTestamentBooks
        .any((nt) => bookCode.contains(nt) || nt.contains(bookCode))) {
      return 'eBookKinhThanhTanUoc.pdf';
    }

    // Mặc định là Cựu Ước
    return 'eBookKinhThanhCuuUoc.pdf';
  }

  static Future<DailyReading?> getTodayReading() async {
    final readings = await parseCalendarPdf();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return readings[todayKey];
  }

  static Future<DailyReading?> getReadingForDate(DateTime date) async {
    final readings = await parseCalendarPdf();
    final dateKey = DateTime(date.year, date.month, date.day);

    return readings[dateKey];
  }
}
