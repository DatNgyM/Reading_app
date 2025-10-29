import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import 'verse_result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoritePassage> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('favorite_passages') ?? '[]';
    try {
      final List data = json.decode(raw) as List;
      setState(() {
        _favorites = data.map((e) => FavoritePassage.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _favorites = [];
        _loading = false;
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_favorites.map((e) => e.toMap()).toList());
    await prefs.setString('favorite_passages', raw);
  }

  void _removeAt(int index) {
    final removed = _favorites[index];
    setState(() => _favorites.removeAt(index));
    _saveFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xoá "${removed.title}" khỏi yêu thích')),
    );
  }

  void _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá tất cả'),
        content: const Text('Bạn có chắc muốn xoá tất cả mục yêu thích?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xoá')),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _favorites.clear());
      _saveFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
        backgroundColor: AppTheme.primaryLight,
        actions: [
          if (!_loading && _favorites.isNotEmpty)
            IconButton(
              tooltip: 'Xoá tất cả',
              icon: const Icon(Icons.delete_forever),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có đoạn yêu thích.\nLưu đoạn từ trang tìm kiếm để xem lại ở đây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final f = _favorites[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(f.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          f.content.length > 200
                              ? '${f.content.substring(0, 200)}...'
                              : f.content,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => VerseResultScreen(
                                  title: f.title, content: f.content)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeAt(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

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
