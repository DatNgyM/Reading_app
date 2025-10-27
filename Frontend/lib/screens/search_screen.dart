import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bible_pdf_service.dart';
import '../services/liturgical_calendar_service.dart';
import '../models/daily_reading.dart';
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

    // Tìm trong Kinh Thánh
    if (_searchType == 'Tất cả' || _searchType == 'Sách Kinh Thánh') {
      results.addAll(await _searchBibleBooks(query));
    }

    // Tìm trong lịch đọc
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

    // Tìm trong Cựu Ước
    final oldTestament = BiblePdfService.getOldTestamentBooks();
    for (var entry in oldTestament.entries) {
      if (entry.key.toLowerCase().contains(queryLower) ||
          entry.value.fullName.toLowerCase().contains(queryLower)) {
        results.add(SearchResult(
          title: entry.value.fullName,
          subtitle: '${entry.key} • ${entry.value.totalChapters} chương',
          type: 'Cựu Ước',
          icon: Icons.book,
          color: Colors.blue,
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

    // Tìm trong Tân Ước
    final newTestament = BiblePdfService.getNewTestamentBooks();
    for (var entry in newTestament.entries) {
      if (entry.key.toLowerCase().contains(queryLower) ||
          entry.value.fullName.toLowerCase().contains(queryLower)) {
        results.add(SearchResult(
          title: entry.value.fullName,
          subtitle: '${entry.key} • ${entry.value.totalChapters} chương',
          type: 'Tân Ước',
          icon: Icons.menu_book,
          color: Colors.green,
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
      final readings = await LiturgicalCalendarService.parseCalendarPdf();

      for (var entry in readings.entries) {
        final reading = entry.value;

        // Tìm theo tên thánh hoặc bài đọc
        if (reading.saintName.toLowerCase().contains(queryLower) ||
            reading.readings.any((r) =>
                r.book.toLowerCase().contains(queryLower) ||
                r.fullReference.toLowerCase().contains(queryLower))) {
          results.add(SearchResult(
            title: reading.saintName,
            subtitle: reading.date.toString().substring(0, 10),
            type: 'Lịch đọc',
            icon: Icons.calendar_today,
            color: Colors.red,
            onTap: () {
              if (reading.readings.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyReadingScreen(
                      reading: reading.readings.first, date: '',
                    ),
                  ),
                );
              }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm sách, thánh, bài đọc...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => _performSearch(value),
                  onSubmitted: (value) => _performSearch(value),
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _searchTypes.map((type) {
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
                          selectedColor: Colors.red[100],
                          checkmarkColor: Colors.red[700],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tìm kiếm sách, thánh, bài đọc',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: result.color.withOpacity(0.2),
              child: Icon(result.icon, color: result.color),
            ),
            title: Text(
              result.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(result.subtitle),
            trailing: Chip(
              label: Text(
                result.type,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: result.color.withOpacity(0.1),
              labelStyle: TextStyle(color: result.color),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              result.onTap();
            },
          ),
        );
      },
    );
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
