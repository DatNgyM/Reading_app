class ReadingContent {
  final String type;
  final String book;
  final String chapters;
  final String content;

  ReadingContent({
    required this.type,
    required this.book,
    required this.chapters,
    required this.content,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'book': book,
        'chapters': chapters,
        'content': content,
      };

  factory ReadingContent.fromMap(Map<String, dynamic> m) => ReadingContent(
        type: m['type'] ?? '',
        book: m['book'] ?? '',
        chapters: m['chapters'] ?? '',
        content: m['content'] ?? '',
      );
}
