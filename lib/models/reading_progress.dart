class ReadingProgress {
  final String readingId;
  final double progress; // 0.0 to 1.0
  final DateTime lastReadAt;
  final int totalReadingTime; // phút
  final List<String> bookmarks;
  final List<ReadingNote> notes;
  final List<Highlight> highlights;

  ReadingProgress({
    required this.readingId,
    required this.progress,
    required this.lastReadAt,
    this.totalReadingTime = 0,
    this.bookmarks = const [],
    this.notes = const [],
    this.highlights = const [],
  });

  ReadingProgress copyWith({
    String? readingId,
    double? progress,
    DateTime? lastReadAt,
    int? totalReadingTime,
    List<String>? bookmarks,
    List<ReadingNote>? notes,
    List<Highlight>? highlights,
  }) {
    return ReadingProgress(
      readingId: readingId ?? this.readingId,
      progress: progress ?? this.progress,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
      highlights: highlights ?? this.highlights,
    );
  }
}

class ReadingNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? position; // Vị trí trong bài đọc
  final String? color;

  ReadingNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.position,
    this.color,
  });
}

class Highlight {
  final String id;
  final String text;
  final String? color;
  final DateTime createdAt;
  final String? position;

  Highlight({
    required this.id,
    required this.text,
    this.color,
    required this.createdAt,
    this.position,
  });
}
