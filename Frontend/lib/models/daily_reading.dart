class ReadingReference {
  final String type;
  final String book;
  final String chapters;
  final String pdfFile;

  ReadingReference({
    required this.type,
    required this.book,
    required this.chapters,
    required this.pdfFile,
  });

  factory ReadingReference.fromJson(Map<String, dynamic> json) {
    return ReadingReference(
      type: json['type'] ?? '',
      book: json['book'] ?? '',
      chapters: json['chapters'] ?? '',
      pdfFile: json['pdfFile'] ?? 'eBookKinhThanhCuuUoc.pdf',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'book': book,
      'chapters': chapters,
      'pdfFile': pdfFile,
    };
  }

  String get fullReference => '$book $chapters';
}

class DailyReading {
  final String date; // Format: "2025-01-01"
  final String saintName;
  final List<ReadingReference> readings;
  final String? note;

  DailyReading({
    required this.date,
    required this.saintName,
    required this.readings,
    this.note,
  });

  factory DailyReading.fromJson(String date, Map<String, dynamic> json) {
    List<ReadingReference> readingsList = [];
    if (json['readings'] != null) {
      readingsList = (json['readings'] as List)
          .map((r) => ReadingReference.fromJson(r))
          .toList();
    }

    return DailyReading(
      date: date,
      saintName: json['saintName'] ?? '',
      readings: readingsList,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saintName': saintName,
      'readings': readings.map((r) => r.toJson()).toList(),
      if (note != null) 'note': note,
    };
  }

  /// Số lượng bài đọc
  int get readingCount => readings.length;

  /// Có bài đọc không
  bool get hasReadings => readings.isNotEmpty;

  /// Lấy bài Tin Mừng
  ReadingReference? get gospel {
    try {
      return readings.firstWhere((r) => r.type.contains('Tin Mừng'));
    } catch (e) {
      return null;
    }
  }

  /// Lấy tất cả bài đọc (không bao gồm Thi Đáp)
  List<ReadingReference> get mainReadings {
    return readings.where((r) => !r.type.contains('Thi')).toList();
  }
}
