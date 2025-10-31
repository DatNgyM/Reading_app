class FavoritePassage {
  final String title;
  final String content;
  final String savedAt;

  FavoritePassage({
    required this.title,
    required this.content,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'savedAt': savedAt,
      };

  factory FavoritePassage.fromMap(Map<String, dynamic> m) => FavoritePassage(
        title: m['title'] ?? '',
        content: m['content'] ?? '',
        savedAt: m['savedAt'] ?? DateTime.now().toIso8601String(),
      );
}
