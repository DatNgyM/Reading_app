import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';
import 'verse_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _debounce;

  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String _searchType = 'Tất cả';

  final List<String> _searchTypes = [
    'Tất cả',
    'Sách Kinh Thánh',
    'Bài đọc hàng ngày'
  ];

  Map<String, dynamic>? _cuuUocMap;
  Map<String, dynamic>? _tanUocMap;
  bool _bibleJsonLoaded = false;

  // Hiển thị trực tiếp nội dung đoạn/chương dưới thanh tìm kiếm
  String? _directTitle;
  String? _directContent;

  // Favorites
  List<FavoritePassage> _favorites = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadFavorites();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favorite_passages') ?? '[]';
      final List data = json.decode(raw) as List;
      setState(() {
        _favorites = data.map((e) => FavoritePassage.fromMap(e)).toList();
      });
    } catch (e) {
      print('Load favorites error: $e');
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_favorites.map((e) => e.toMap()).toList());
    await prefs.setString('favorite_passages', raw);
  }

  void _addFavorite(String title, String content) {
    final exists =
        _favorites.any((f) => f.title == title && f.content == content);
    if (exists) return;
    final f = FavoritePassage(
      title: title,
      content: content,
      savedAt: DateTime.now().toIso8601String(),
    );
    setState(() {
      _favorites.insert(0, f);
    });
    _saveFavorites();
  }

  void _removeFavorite(FavoritePassage f) {
    setState(() {
      _favorites.removeWhere(
          (item) => item.savedAt == f.savedAt && item.title == f.title);
    });
    _saveFavorites();
  }

  // Thay thế/ghi đè _performSearch để hỗ trợ định dạng:
  // - "Gioan 1:1-10"
  // - "luca 2, 2-24"  (dấu phẩy phân tách chương và verses)
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

    // Patterns:
    final patternA = RegExp(r'^(.+?)\s+(\d+)\s*:\s*(\d+)(?:\s*-\s*(\d+))?$',
        caseSensitive: false);
    final patternB = RegExp(r'^(.+?)\s+(\d+)\s*,\s*(\d+)(?:\s*-\s*(\d+))?$',
        caseSensitive: false);
    final patternC = RegExp(r'^(.+?)\s+(\d+)$',
        caseSensitive: false); // <-- Book + Chapter only

    // Try A or B first (chapter:verse or chapter, verses)
    Match? m = patternA.firstMatch(q) ?? patternB.firstMatch(q);

    if (m != null) {
      try {
        await _ensureBibleJsonLoaded();
        final bookRaw = m.group(1)!.trim();
        final chapter = int.parse(m.group(2)!);
        final startVerse = int.parse(m.group(3)!);
        final endVerse =
            m.group(4) != null ? int.parse(m.group(4)!) : startVerse;

        final lookup = _lookupVerses(bookRaw, chapter, startVerse, endVerse);
        // Hiển thị trực tiếp nội dung dưới thanh tìm kiếm (không ra thẻ)
        setState(() {
          _directTitle = lookup['title'];
          _directContent = lookup['content'];
          _searchResults = [];
          _isLoading = false;
        });
        return;
      } catch (e) {
        print('Verse lookup error: $e');
        // fallback to normal search
      }
    }

    // Handle patternC: "Book Chapter" => whole chapter
    final mC = patternC.firstMatch(q);
    if (mC != null) {
      try {
        await _ensureBibleJsonLoaded();
        final bookRaw = mC.group(1)!.trim();
        final chapter = int.parse(mC.group(2)!);
        final bookKey = _mapBookName(bookRaw);

        Map<String, dynamic>? bookData =
            _tanUocMap?[bookKey] ?? _cuuUocMap?[bookKey];
        // fallback variants
        if (bookData == null) {
          final alt = bookKey.replaceAll(RegExp(r'\s+'), ' ');
          bookData = _tanUocMap?[alt] ?? _cuuUocMap?[alt];
        }

        final title = '$bookKey $chapter';
        if (bookData == null) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseResultScreen(
                title: title,
                content: 'Không tìm thấy sách "$bookRaw" trong dữ liệu.',
              ),
            ),
          );
          return;
        }

        final chapterData = bookData['$chapter'] as Map<String, dynamic>?;
        if (chapterData == null) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseResultScreen(
                title: title,
                content: 'Không tìm thấy chương $chapter trong sách $bookKey.',
              ),
            ),
          );
          return;
        }

        // tìm câu cuối cùng trong chương
        int lastVerse = 0;
        for (var k in chapterData.keys) {
          final n = int.tryParse(k.toString());
          if (n != null && n > lastVerse) lastVerse = n;
        }
        if (lastVerse == 0) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseResultScreen(
                title: title,
                content:
                    'Chương $chapter trong sách $bookKey không chứa câu nào trong dữ liệu.',
              ),
            ),
          );
          return;
        }

        final lookup = _lookupVerses(bookRaw, chapter, 1, lastVerse);
        // Hiển thị trực tiếp nội dung cả chương
        setState(() {
          _directTitle = lookup['title'];
          _directContent = lookup['content'];
          _searchResults = [];
          _isLoading = false;
        });
        return;
      } catch (e) {
        print('Whole-chapter lookup error: $e');
        // fallback to normal search
      }
    }

    // fallback: normal search across Bible/books or daily readings
    List<SearchResult> results = [];

    if (_searchType == 'Tất cả' || _searchType == 'Sách Kinh Thánh') {
      results.addAll(await _searchBibleBooks(query));
    }

    if (_searchType == 'Tất cả' || _searchType == 'Bài đọc hàng ngày') {
      results.addAll(await _searchDailyReadings(query));
    }

    setState(() {
      _searchResults = results;
      _directTitle = null;
      _directContent = null;
      _isLoading = false;
    });
  }

  Future<void> _ensureBibleJsonLoaded() async {
    if (_bibleJsonLoaded) return;
    final cuu = await rootBundle.loadString('assets/data/Cuu_uoc.json');
    final tan = await rootBundle.loadString('assets/data/Tan_uoc.json');
    _cuuUocMap = json.decode(cuu) as Map<String, dynamic>;
    _tanUocMap = json.decode(tan) as Map<String, dynamic>;
    _bibleJsonLoaded = true;
  }

  // Mapping đầy đủ (NT + CT) tên sách variants -> key trong JSON của bạn.
  String _mapBookName(String raw) {
    final r = raw.trim();
    final key = r.replaceAll(RegExp(r'\s+'), ' ');

    // Các mapping viết tắt/biến thể tiếng Việt (key ở dạng lowercase)
    final Map<String, String> map = {
      // Ngũ Thư / Cựu Ước cơ bản
      'st': 'Sáng Thế Ký', 'stk': 'Sáng Thế Ký', 'sáng thế ký': 'Sáng Thế Ký',
      'sáng thế': 'Sáng Thế Ký',
      'xh': 'Xuất Hành', 'xuất hành': 'Xuất Hành',
      'lv': 'Lê-vi', 'lê-vi': 'Lê-vi',
      'ds': 'Dân Số', 'dân số': 'Dân Số',
      'dnl': 'Đệ Nhị Luật', 'đệ nhị luật': 'Đệ Nhị Luật',

      // Sách lịch sử
      'tl': 'Thủ Lãnh', 'thủ lãnh': 'Thủ Lãnh',
      'ru': 'Rút', 'rút': 'Rút',
      '1sm': 'Samuen 1', '2sm': 'Samuen 2', 'samuen': 'Samuen 1',
      'samuel': 'Samuen 1',
      '1vua': 'Vua 1', '2vua': 'Vua 2',
      '1sb': 'Sử Biên 1', '2sb': 'Sử Biên 2',

      // Một số sách khác CT
      'ezr': 'Étra', 'neh': 'NơKhemia', 'tb': 'Tôbia',

      // Thơ ca / Khôn ngoan
      'ps': 'Thánh Vịnh', 'tv': 'Thánh Vịnh', 'thánh vịnh': 'Thánh Vịnh',
      'cn': 'Châm Ngôn', 'châm ngôn': 'Châm Ngôn',
      'gv': 'Giảng Viên', 'giảng viên': 'Giảng Viên',
      'dt': 'Diễm Ca', 'diễm ca': 'Diễm Ca',
      'kn': 'Khôn Ngoan', 'hc': 'Huấn Ca',

      // Tiên tri (chọn tên gần nhất)
      'isa': 'I-sai-a', 'i-sai-a': 'I-sai-a', 'i sai a': 'I-sai-a',
      'jer': 'Giêrêmia', 'giêrêmia': 'Giêrêmia',
      'ezek': 'Êdêkien', 'ênêkien': 'Êdêkien', 'đanien': 'Đanien',
      'hosea': 'Hôsê', 'joel': 'Giôen', 'amos': 'A-mốt', 'obad': 'Ôvađia',
      'jonah': 'Giôna', 'mic': 'Mikha', 'nah': 'Nakhum', 'hab': 'Khabarúc',
      'zeph': 'Xôphônia', 'hag': 'Khácgai', 'zec': 'Dacaria', 'mal': 'Malakhi',

      // Phúc Âm / Tân Ước (viết tắt phổ biến)
      'mt': 'Mátthêu', 'mátthêu': 'Mátthêu', 'matthew': 'Mátthêu',
      'mc': 'Máccô', 'máccô': 'Máccô', 'mark': 'Máccô',
      'lc': 'Luca', 'luca': 'Luca', 'luke': 'Luca',
      'jn': 'Gioan', 'gioan': 'Gioan', 'john': 'Gioan',

      // Thư NT (viết tắt)
      'cv': 'Công vụ Tông đồ', 'acts': 'Công vụ Tông đồ',
      'rm': 'Thư Rôma', 'rôma': 'Thư Rôma', 'roma': 'Thư Rôma',
      '1cr': 'Thư Côrintô', '2cr': 'Thư Côrintô',
      'gl': 'Thư Galát', 'ep': 'Thư Êphêsô', 'eph': 'Thư Êphêsô',
      'pl': 'Thư Philípphê', 'cl': 'Thư Côlôxê',
      '1tx': 'Thư Thêxalônica 1', '2tx': 'Thư Thêxalônica 2',
      '1tm': 'Thư Timôthê 1', '2tm': 'Thư Timôthê 2',
      'tt': 'Thư Titô', 'plm': 'Thư Philêmon', 'dt_nt': 'Thư Do thái',
      'gc': 'Thư Giacôbê', '1pr': 'Thư Phêrô 1', '2pr': 'Thư Phêrô 2',
      '1ga': 'Thư Gioan 1', '2ga': 'Thư Gioan 2', '3ga': 'Thư Gioan 3',
      'gd': 'Thư Giuđa', 'kh': 'Khải Huyền',
    };

    final lower = key.toLowerCase();
    if (map.containsKey(lower)) return map[lower]!;
    if (map.containsKey(r)) return map[r]!;
    if (map.containsKey(r.toLowerCase())) return map[r.toLowerCase()]!;
    // fallback: trả về key đã chuẩn hóa
    return key[0].toUpperCase() + key.substring(1);
  }

  // Trả về {'title':..., 'content':...}
  Map<String, String?> _lookupVerses(
      String bookRaw, int chapter, int startVerse, int endVerse) {
    final bookKey = _mapBookName(bookRaw);
    Map<String, dynamic>? bookData =
        _tanUocMap?[bookKey] ?? _cuuUocMap?[bookKey];

    // Try alternative keys (remove accents/spaces)
    if (bookData == null) {
      final alt = bookKey.replaceAll(RegExp(r'\s+'), ' ');
      bookData = _tanUocMap?[alt] ?? _cuuUocMap?[alt];
    }

    final title =
        '$bookKey $chapter:$startVerse${startVerse != endVerse ? '-$endVerse' : ''}';
    if (bookData == null) {
      return {
        'title': title,
        'content': 'Không tìm thấy sách "$bookRaw" trong dữ liệu.'
      };
    }

    final chapterData = bookData['$chapter'] as Map<String, dynamic>?;
    if (chapterData == null) {
      return {
        'title': title,
        'content': 'Không tìm thấy chương $chapter trong sách $bookKey.'
      };
    }

    final buffer = StringBuffer();
    for (int v = startVerse; v <= endVerse; v++) {
      final verseText = chapterData['$v'];
      if (verseText != null) {
        buffer.writeln('$v. $verseText\n');
      } else {
        buffer.writeln('$v. [Không tìm thấy câu $v]\n');
      }
    }

    return {'title': title, 'content': buffer.toString()};
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

  // Debounced onChanged handler
  void _onSearchChanged(String value) {
    // nếu còn timer đang chạy thì hủy
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // delay trước khi thực hiện tìm kiếm (500ms)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value);
    });
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
                  // Hiển thị mẫu bên trong ô tìm kiếm, mờ nhẹ
                  hintText: 'luca 1, 1-24',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.45)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.primaryLight),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                              color: AppTheme.primaryLight,
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded),
                              onPressed: () {
                                // Chỉ tìm khi bấm nút
                                _performSearch(_searchController.text);
                              },
                              color: AppTheme.primaryLight,
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded),
                          onPressed: () {
                            // nếu chưa nhập gì thì vẫn không tìm
                            if (_searchController.text.trim().isNotEmpty) {
                              _performSearch(_searchController.text);
                            }
                          },
                          color: AppTheme.primaryLight,
                        ),
                  border: InputBorder.none,
                ),
                // Không tự tìm khi gõ hoặc Enter; chỉ tìm khi bấm nút (arrow_forward_rounded)
                onChanged: null,
                onSubmitted: null,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
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

            // Nơi hiển thị nội dung trực tiếp (đoạn / chương) hoặc danh sách kết quả
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _directContent != null
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_directTitle != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0, top: 4),
                                        child: Text(
                                          _directTitle!,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    // Save / Unsave button
                                    IconButton(
                                      tooltip: 'Lưu vào yêu thích',
                                      icon: Icon(
                                        _favorites.any((f) =>
                                                f.title == _directTitle &&
                                                f.content == _directContent)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _favorites.any((f) =>
                                                f.title == _directTitle &&
                                                f.content == _directContent)
                                            ? Colors.red
                                            : AppTheme.primaryLight,
                                      ),
                                      onPressed: () {
                                        final isFav = _favorites.any((f) =>
                                            f.title == _directTitle &&
                                            f.content == _directContent);
                                        if (isFav) {
                                          final f = _favorites.firstWhere((f) =>
                                              f.title == _directTitle &&
                                              f.content == _directContent);
                                          _removeFavorite(f);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Đã xoá khỏi yêu thích')));
                                        } else {
                                          _addFavorite(_directTitle ?? '',
                                              _directContent ?? '');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Đã lưu vào yêu thích')));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isDark ? AppTheme.cardDark : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: SelectableText(
                                  _directContent ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _searchResults.isEmpty
                          ? _favorites.isEmpty
                              ? Center(
                                  child: Text(
                                    'Không có kết quả. Nhập định dạng: "luca 1, 1-24" hoặc "Gioan 1:1-10" rồi bấm mũi tên.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                )
                              // Show favorites list when no direct content and no search results
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount: _favorites.length,
                                  itemBuilder: (context, idx) {
                                    final f = _favorites[idx];
                                    return Card(
                                      margin: const EdgeInsets.only(
                                          bottom: 12, top: 6),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: const Icon(Icons.favorite,
                                            color: Colors.red),
                                        title: Text(f.title),
                                        subtitle: Text(
                                          f.content.length > 120
                                              ? '${f.content.substring(0, 120)}...'
                                              : f.content,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          // Mở full view
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VerseResultScreen(
                                                  title: f.title,
                                                  content: f.content),
                                            ),
                                          );
                                        },
                                        trailing: IconButton(
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          onPressed: () {
                                            _removeFavorite(f);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Đã xoá khỏi yêu thích')));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final r = _searchResults[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.only(bottom: 12, top: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: Icon(r.icon,
                                        color: AppTheme.primaryLight),
                                    title: Text(r.title),
                                    subtitle: Text(r.subtitle),
                                    onTap: r.onTap,
                                  ),
                                );
                              },
                            ),
            ),
          ],
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

class FavoritePassage {
  final String title;
  final String content;
  final String savedAt; // ISO string to identify uniquely

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
