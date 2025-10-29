import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bible_pdf_service.dart';
import '../services/json_liturgical_service.dart';
import '../utils/app_theme.dart';
import 'reading_screen.dart';
import 'daily_reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String _searchType = 'Tất cả';

  final List<String> _searchTypes = [
    'Tất cả',
    'Sách Kinh Thánh',
    'Bài đọc hàng ngày'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    List<SearchResult> results = [];

    if (_searchType == 'Tất cả' || _searchType == 'Sách Kinh Thánh') {
      results.addAll(await _searchBibleBooks(query));
    }

    if (_searchType == 'Tất cả' || _searchType == 'Bài đọc hàng ngày') {
      results.addAll(await _searchDailyReadings(query));
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<List<SearchResult>> _searchBibleBooks(String query) async {
    List<SearchResult> results = [];
    final queryLower = query.toLowerCase();

    final oldTestament = BiblePdfService.getOldTestamentBooks();
    for (var entry in oldTestament.entries) {
      if (entry.key.toLowerCase().contains(queryLower) ||
          entry.value.fullName.toLowerCase().contains(queryLower)) {
        results.add(SearchResult(
          title: entry.value.fullName,
          subtitle: '${entry.key} • ${entry.value.totalChapters} chương',
          type: 'Cựu Ước',
          icon: Icons.book_rounded,
          gradientColors: AppTheme.coolGradient,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingScreen(
                  bookCode: entry.key,
                  bookInfo: entry.value,
                  pdfFile: 'eBookKinhThanhCuuUoc.pdf',
                ),
              ),
            );
          },
        ));
      }
    }

    final newTestament = BiblePdfService.getNewTestamentBooks();
    for (var entry in newTestament.entries) {
      if (entry.key.toLowerCase().contains(queryLower) ||
          entry.value.fullName.toLowerCase().contains(queryLower)) {
        results.add(SearchResult(
          title: entry.value.fullName,
          subtitle: '${entry.key} • ${entry.value.totalChapters} chương',
          type: 'Tân Ước',
          icon: Icons.menu_book_rounded,
          gradientColors: [AppTheme.primaryLight, AppTheme.secondaryLight],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingScreen(
                  bookCode: entry.key,
                  bookInfo: entry.value,
                  pdfFile: 'eBookKinhThanhTanUoc.pdf',
                ),
              ),
            );
          },
        ));
      }
    }

    return results;
  }

  Future<List<SearchResult>> _searchDailyReadings(String query) async {
    List<SearchResult> results = [];
    final queryLower = query.toLowerCase();

    try {
      final readings = await JsonLiturgicalService.loadFromJson();

      for (var entry in readings.entries) {
        final reading = entry.value;

        if (reading.saintName.toLowerCase().contains(queryLower) ||
            reading.readings.any((r) =>
                r.book.toLowerCase().contains(queryLower) ||
                r.fullReference.toLowerCase().contains(queryLower))) {
          results.add(SearchResult(
            title: reading.saintName,
            subtitle: reading.date,
            type: 'Lịch đọc',
            icon: Icons.calendar_today_rounded,
            gradientColors: AppTheme.warmGradient,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyReadingScreen(
                    date: reading.date,
                  ),
                ),
              );
            },
          ));
        }
      }
    } catch (e) {
      print('Error searching readings: $e');
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                title: Text(
                  'Tìm Kiếm',
                  style: const TextStyle(
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
            // Modern Search Bar
            Container(
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
                  hintText: 'Tìm sách, thánh, bài đọc...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.primaryLight),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                          color: AppTheme.primaryLight,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textTertiaryDark
                        : AppTheme.textTertiaryLight,
                  ),
                ),
                onChanged: (value) => _performSearch(value),
                onSubmitted: (value) => _performSearch(value),
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ),

            // Filter Chips
            Container(
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
                        setState(() {
                          _searchType = type;
                        });
                        _performSearch(_searchController.text);
                      },
                      selectedColor: AppTheme.primaryLight,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor:
                          isDark ? AppTheme.cardDark : Colors.white,
                      side: BorderSide(
                        color: AppTheme.primaryLight.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Results
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 50,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tìm kiếm sách, thánh, bài đọc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập từ khóa để bắt đầu tìm kiếm',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử lại với từ khóa khác',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildResultCard(result, isDark);
      },
    );
  }

  Widget _buildResultCard(SearchResult result, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: result.gradientColors[0].withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            result.onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: result.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: result.gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(result.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: result.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });
}
