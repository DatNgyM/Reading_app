import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../services/favorites_service.dart';
import '../models/favorite_passage.dart';
import '../models/search_result.dart';
import 'verse_result_screen.dart';
import '../utils/app_theme.dart';
import 'daily_reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final FavoritesService _favoritesService = FavoritesService();

  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String _searchType = 'Tất cả';

  final List<String> _searchTypes = [
    'Tất cả',
    'Sách Kinh Thánh',
    'Bài đọc hàng ngày'
  ];

  String? _directTitle;
  String? _directContent;
  List<FavoritePassage> _favorites = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.loadFavorites();
    setState(() => _favorites = favorites);
  }

  Future<void> _addFavorite(String title, String content) async {
    final updated = _favoritesService.addFavorite(_favorites, title, content);
    setState(() => _favorites = updated);
    await _favoritesService.saveFavorites(_favorites);
  }

  Future<void> _removeFavorite(FavoritePassage f) async {
    final updated = _favoritesService.removeFavorite(_favorites, f);
    setState(() => _favorites = updated);
    await _favoritesService.saveFavorites(_favorites);
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _directTitle = null;
        _directContent = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _directTitle = null;
      _directContent = null;
    });

    // Try direct lookup first
    final directResult = await _searchService.parseDirectLookup(q);
    if (directResult != null) {
      setState(() {
        _directTitle = directResult['title'];
        _directContent = directResult['content'];
        _isLoading = false;
      });
      return;
    }

    // Fallback: normal search
    List<SearchResult> results = [];

    if (_searchType == 'Tất cả' || _searchType == 'Sách Kinh Thánh') {
      final bibleResults = await _searchService.searchBibleBooks(query);
      for (var item in bibleResults) {
        results.add(SearchResult(
          title: item['title'],
          subtitle: item['subtitle'],
          type: item['type'],
          icon: Icons.book_rounded,
          gradientColors: [AppTheme.primaryLight, AppTheme.secondaryLight],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerseResultScreen(
                  title: item['previewTitle'],
                  content: item['previewContent'],
                ),
              ),
            );
          },
        ));
      }
    }

    if (_searchType == 'Tất cả' || _searchType == 'Bài đọc hàng ngày') {
      final readingResults = await _searchService.searchDailyReadings(query);
      for (var item in readingResults) {
        results.add(SearchResult(
          title: item['title'],
          subtitle: item['subtitle'],
          type: item['type'],
          icon: Icons.calendar_today_rounded,
          gradientColors: AppTheme.warmGradient,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DailyReadingScreen(date: item['date']),
              ),
            );
          },
        ));
      }
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = _favoritesService.isFavorite(
      _favorites,
      _directTitle ?? '',
      _directContent ?? '',
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryLight,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: const Text(
                  'Tìm Kiếm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppTheme.primaryGradient,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            _buildSearchBar(isDark),
            _buildFilterChips(isDark),
            const SizedBox(height: 8),
            Expanded(
              child: _buildContent(isDark, isFavorite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'luca 1, 1-24',
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.45)),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppTheme.primaryLight),
          suffixIcon: _searchController.text.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _directTitle = null;
                          _directContent = null;
                        });
                      },
                      color: AppTheme.primaryLight,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () => _performSearch(_searchController.text),
                      color: AppTheme.primaryLight,
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () {
                    if (_searchController.text.trim().isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                  color: AppTheme.primaryLight,
                ),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.grey[800], fontSize: 16),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _searchTypes.length,
        itemBuilder: (context, index) {
          final type = _searchTypes[index];
          final isSelected = _searchType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _searchType = type);
                _performSearch(_searchController.text);
              },
              selectedColor: AppTheme.primaryLight,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
              side: BorderSide(
                color: AppTheme.primaryLight.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isFavorite) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_directContent != null) {
      return _buildDirectContent(isDark, isFavorite);
    }

    if (_searchResults.isEmpty) {
      return _favorites.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(isDark);
    }

    return _buildSearchResults();
  }

  Widget _buildDirectContent(bool isDark, bool isFavorite) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_directTitle != null)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                    child: Text(
                      _directTitle!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Lưu vào yêu thích',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : AppTheme.primaryLight,
                  ),
                  onPressed: () async {
                    if (isFavorite) {
                      final f = _favorites.firstWhere((f) =>
                          f.title == _directTitle &&
                          f.content == _directContent);
                      await _removeFavorite(f);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Đã xoá khỏi yêu thích')),
                        );
                      }
                    } else {
                      await _addFavorite(
                          _directTitle ?? '', _directContent ?? '');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu vào yêu thích')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: SelectableText(
              _directContent ?? '',
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Không có kết quả. Nhập định dạng: "luca 1, 1-24" hoặc "Gioan 1:1-10" rồi bấm mũi tên.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildFavoritesList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _favorites.length,
      itemBuilder: (context, idx) {
        final f = _favorites[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12, top: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(f.title),
            subtitle: Text(
              f.content.length > 120
                  ? '${f.content.substring(0, 120)}...'
                  : f.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VerseResultScreen(title: f.title, content: f.content),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _removeFavorite(f);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xoá khỏi yêu thích')),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final r = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12, top: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(r.icon, color: AppTheme.primaryLight),
            title: Text(r.title),
            subtitle: Text(r.subtitle),
            onTap: r.onTap,
          ),
        );
      },
    );
  }
}
