import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_passage.dart';

class FavoritesService {
  static const String _storageKey = 'favorite_passages';

  // Load favorites from storage
  Future<List<FavoritePassage>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey) ?? '[]';
      final List data = json.decode(raw) as List;
      return data.map((e) => FavoritePassage.fromMap(e)).toList();
    } catch (e) {
      print('Load favorites error: $e');
      return [];
    }
  }

  // Save favorites to storage
  Future<void> saveFavorites(List<FavoritePassage> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(favorites.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      print('Save favorites error: $e');
    }
  }

  // Add a favorite (returns updated list)
  List<FavoritePassage> addFavorite(
    List<FavoritePassage> currentFavorites,
    String title,
    String content,
  ) {
    final exists = currentFavorites.any(
      (f) => f.title == title && f.content == content,
    );
    if (exists) return currentFavorites;

    final newFavorite = FavoritePassage(
      title: title,
      content: content,
      savedAt: DateTime.now().toIso8601String(),
    );

    return [newFavorite, ...currentFavorites];
  }

  // Remove a favorite (returns updated list)
  List<FavoritePassage> removeFavorite(
    List<FavoritePassage> currentFavorites,
    FavoritePassage toRemove,
  ) {
    return currentFavorites
        .where((item) =>
            item.savedAt != toRemove.savedAt || item.title != toRemove.title)
        .toList();
  }

  // Check if favorite exists
  bool isFavorite(
    List<FavoritePassage> favorites,
    String title,
    String content,
  ) {
    return favorites.any((f) => f.title == title && f.content == content);
  }
}
