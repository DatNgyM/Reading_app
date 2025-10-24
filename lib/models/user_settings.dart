class UserSettings {
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;
  final int dailyReadingGoal; // phút
  final String preferredDifficulty;
  final List<String> favoriteCategories;
  final bool autoPlayAudio;
  final double fontSize;
  final bool enableHapticFeedback;
  final String readingMode; // scroll, page
  final bool enableBookmarks;
  final bool enableNotes;
  final bool enableHighlights;
  final Map<String, dynamic> customSettings;

  UserSettings({
    this.darkMode = false,
    this.language = 'vi',
    this.notificationsEnabled = true,
    this.dailyReadingGoal = 30,
    this.preferredDifficulty = 'Medium',
    this.favoriteCategories = const [],
    this.autoPlayAudio = false,
    this.fontSize = 16.0,
    this.enableHapticFeedback = true,
    this.readingMode = 'scroll',
    this.enableBookmarks = true,
    this.enableNotes = true,
    this.enableHighlights = true,
    this.customSettings = const {},
  });

  UserSettings copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
    int? dailyReadingGoal,
    String? preferredDifficulty,
    List<String>? favoriteCategories,
    bool? autoPlayAudio,
    double? fontSize,
    bool? enableHapticFeedback,
    String? readingMode,
    bool? enableBookmarks,
    bool? enableNotes,
    bool? enableHighlights,
    Map<String, dynamic>? customSettings,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReadingGoal: dailyReadingGoal ?? this.dailyReadingGoal,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      fontSize: fontSize ?? this.fontSize,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      readingMode: readingMode ?? this.readingMode,
      enableBookmarks: enableBookmarks ?? this.enableBookmarks,
      enableNotes: enableNotes ?? this.enableNotes,
      enableHighlights: enableHighlights ?? this.enableHighlights,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'dailyReadingGoal': dailyReadingGoal,
      'preferredDifficulty': preferredDifficulty,
      'favoriteCategories': favoriteCategories,
      'autoPlayAudio': autoPlayAudio,
      'fontSize': fontSize,
      'enableHapticFeedback': enableHapticFeedback,
      'readingMode': readingMode,
      'enableBookmarks': enableBookmarks,
      'enableNotes': enableNotes,
      'enableHighlights': enableHighlights,
      'customSettings': customSettings,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'vi',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dailyReadingGoal: json['dailyReadingGoal'] ?? 30,
      preferredDifficulty: json['preferredDifficulty'] ?? 'Medium',
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
      autoPlayAudio: json['autoPlayAudio'] ?? false,
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      readingMode: json['readingMode'] ?? 'scroll',
      enableBookmarks: json['enableBookmarks'] ?? true,
      enableNotes: json['enableNotes'] ?? true,
      enableHighlights: json['enableHighlights'] ?? true,
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }
}
