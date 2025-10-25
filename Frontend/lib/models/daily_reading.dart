class DailyReading {
  final DateTime date;
  final String saintName;
  final List<ReadingReference> readings;
  final String liturgicalColor;

  DailyReading({
    required this.date,
    required this.saintName,
    required this.readings,
    this.liturgicalColor = 'green',
  });
}

class ReadingReference {
  final String type; // "Bài Đọc 1", "Thi Đáp", "Tin Mừng"
  final String book; // "1 Ga", "Mc", "Mt"
  final String chapters; // "2:22-28", "4:11-18"
  final String pdfFile; // Tên file PDF

  ReadingReference({
    required this.type,
    required this.book,
    required this.chapters,
    required this.pdfFile,
  });

  String get fullReference => '$book $chapters';
}
