class ReadingItem {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final String category;
  final int readingTime; // phút
  final String difficulty; // Easy, Medium, Hard
  final bool isCompleted;
  final List<String> tags;
  final String? imageUrl;
  final String? audioUrl;
  final double progress; // 0.0 to 1.0
  final bool isBookmarked;
  final int viewCount;
  final double rating;
  final String description;

  ReadingItem({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.category,
    required this.readingTime,
    required this.difficulty,
    this.isCompleted = false,
    this.tags = const [],
    this.imageUrl,
    this.audioUrl,
    this.progress = 0.0,
    this.isBookmarked = false,
    this.viewCount = 0,
    this.rating = 0.0,
    this.description = '',
  });

  ReadingItem copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    DateTime? date,
    String? category,
    int? readingTime,
    String? difficulty,
    bool? isCompleted,
    List<String>? tags,
    String? imageUrl,
    String? audioUrl,
    double? progress,
    bool? isBookmarked,
    int? viewCount,
    double? rating,
    String? description,
  }) {
    return ReadingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      date: date ?? this.date,
      category: category ?? this.category,
      readingTime: readingTime ?? this.readingTime,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      progress: progress ?? this.progress,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'date': date.toIso8601String(),
      'category': category,
      'readingTime': readingTime,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
      'tags': tags,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'progress': progress,
      'isBookmarked': isBookmarked,
      'viewCount': viewCount,
      'rating': rating,
      'description': description,
    };
  }

  factory ReadingItem.fromJson(Map<String, dynamic> json) {
    return ReadingItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      readingTime: json['readingTime'],
      difficulty: json['difficulty'],
      isCompleted: json['isCompleted'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      progress: json['progress'] ?? 0.0,
      isBookmarked: json['isBookmarked'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      rating: json['rating'] ?? 0.0,
      description: json['description'] ?? '',
    );
  }
}
