import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../services/tts_service.dart';

class DailyReadingScreen extends StatefulWidget {
  final String date; // Format: "2025-01-01"

  const DailyReadingScreen({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? lichCongGiao;
  Map<String, dynamic>? cuuUoc;
  Map<String, dynamic>? tanUoc;
  List<ReadingContent> readings = [];

  // TTS tracking
  final TTSService _tts = TTSService();
  bool _isPlaying = false;
  int? _currentPlayingIndex;
  int _currentCharPosition = 0;
  int _startOffsetForResume = 0; // Offset khi resume

  // UI tracking
  int? _expandedIndex; // Index của tile đang mở
  Map<int, GlobalKey> readingKeys = {}; // Keys cho ExpansionTile

  // State persistence
  static const String _stateKey = 'tts_playing';
  static const String _dateKey = 'tts_date';
  static const String _indexKey = 'tts_index';
  static const String _positionKey = 'tts_position';
  int? _savedIndex;
  int _savedPosition = 0;

  @override
  void initState() {
    super.initState();
    _loadReadings();
    _initTTS();
    _loadSavedState();
  }

  Future<void> _initTTS() async {
    await _tts.initialize();

    // Set progress handler để track vị trí chính xác
    _tts.setOnProgressChanged((text, startOffset, endOffset, word) {
      if (_isPlaying && _currentPlayingIndex != null) {
        // Tính vị trí thực tế trong toàn bộ nội dung
        int actualPosition = _startOffsetForResume + startOffset;

        setState(() {
          _currentCharPosition = actualPosition;
        });

        // Debug: In ra vị trí chính xác
        print(
            'TTS Progress: text="$text", startOffset=$startOffset, endOffset=$endOffset, word="$word", actualPosition=$actualPosition');

        // Lưu state mỗi khi có progress
        _saveState();
      }
    });

    _tts.setOnStateChanged(() {
      if (!_tts.isPlaying && _isPlaying) {
        // Finished playing
        setState(() {
          _isPlaying = false;
          _currentPlayingIndex = null;
          _currentCharPosition = 0;
          _startOffsetForResume = 0;
        });
        _clearSavedState();
      }
    });
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasPlaying = prefs.getBool(_stateKey) ?? false;
      final savedDate = prefs.getString(_dateKey);
      final savedIndex = prefs.getInt(_indexKey);
      final savedPosition = prefs.getInt(_positionKey) ?? 0;

      if (wasPlaying && savedDate == widget.date && savedIndex != null) {
        setState(() {
          _savedIndex = savedIndex;
          _savedPosition = savedPosition;
        });
        print(
            'Loaded saved state: index=$savedIndex, position=$savedPosition, date=$savedDate');
      } else {
        print(
            'No saved state found: wasPlaying=$wasPlaying, savedDate=$savedDate, savedIndex=$savedIndex');
      }
    } catch (e) {
      print('Error loading state: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_stateKey, _isPlaying);
      await prefs.setString(_dateKey, _isPlaying ? widget.date : '');
      await prefs.setInt(_indexKey, _currentPlayingIndex ?? -1);
      await prefs.setInt(_positionKey, _currentCharPosition);
    } catch (e) {
      print('Error saving state: $e');
    }
  }

  Future<void> _clearSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_stateKey);
      await prefs.remove(_dateKey);
      await prefs.remove(_indexKey);
      await prefs.remove(_positionKey);
    } catch (e) {
      print('Error clearing state: $e');
    }
  }

  Future<void> _loadReadings() async {
    try {
      setState(() => isLoading = true);

      // Load các file JSON
      final lichCongGiaoJson = await rootBundle.loadString(
        'assets/data/lich_cong_giao_2025.json',
      );
      final cuuUocJson = await rootBundle.loadString(
        'assets/data/Cuu_uoc.json',
      );
      final tanUocJson = await rootBundle.loadString(
        'assets/data/Tan_uoc.json',
      );

      lichCongGiao = json.decode(lichCongGiaoJson);
      cuuUoc = json.decode(cuuUocJson);
      tanUoc = json.decode(tanUocJson);

      // Lấy thông tin ngày
      final dayData = lichCongGiao![widget.date];
      if (dayData == null) {
        throw Exception('Không tìm thấy dữ liệu cho ngày ${widget.date}');
      }

      // Xử lý từng bài đọc
      List<ReadingContent> tempReadings = [];
      final readingsList = dayData['readings'] as List<dynamic>?;

      if (readingsList != null) {
        for (var reading in readingsList) {
          final type = reading['type'] as String;
          final book = reading['book'] as String?;
          final chapters = reading['chapters'] as String?;

          //  BỎ QUA Thánh Vịnh và Thi Đáp
          if (type.toLowerCase().contains('thi') ||
              type.toLowerCase().contains('đáp') ||
              type.toLowerCase().contains('vịnh') ||
              book?.toLowerCase().contains('tv') == true ||
              book?.toLowerCase().contains('thánh vịnh') == true) {
            print('⏭ Bỏ qua: $type ($book)');
            continue;
          }

          if (book != null && chapters != null) {
            final content = _getReadingContent(book, chapters);
            if (content != null) {
              tempReadings.add(ReadingContent(
                type: type,
                book: book,
                chapters: chapters,
                content: content,
              ));
            }
          }
        }
      }

      setState(() {
        readings = tempReadings;
        isLoading = false;
      });

      // Check if should show resume dialog
      if (_savedIndex != null && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showResumeDialog();
          }
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải dữ liệu: $e';
        isLoading = false;
      });
    }
  }

  void _showResumeDialog() {
    if (_savedIndex == null ||
        _savedIndex! < 0 ||
        _savedIndex! >= readings.length) return;

    final reading = readings[_savedIndex!];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiếp tục nghe?'),
        content: Text(
            'Bạn đang nghe bài "${reading.type}".\n\nVị trí: ${_savedPosition}/${reading.content.length} ký tự'),
        actions: [
          TextButton(
            onPressed: () async {
              await _clearSavedState();
              Navigator.pop(context);
            },
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeReading(_savedIndex!);
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  void _resumeReading(int index) async {
    if (index < 0 || index >= readings.length) return;

    final reading = readings[index];

    // Resume từ chính xác vị trí đã lưu
    int startChar = _savedPosition;
    if (startChar < 0) startChar = 0;
    if (startChar >= reading.content.length) startChar = 0;

    // Lưu offset để tính toán vị trí thực tế
    _startOffsetForResume = startChar;

    String remainingContent = reading.content.substring(startChar);
    print(
        'Resume: Starting from exact char $startChar of ${reading.content.length}');
    print(
        'Remaining content: "${remainingContent.substring(0, remainingContent.length > 50 ? 50 : remainingContent.length)}..."');

    await _tts.speak(remainingContent);

    setState(() {
      _currentPlayingIndex = index;
      _isPlaying = true;
      _currentCharPosition = startChar;
    });

    await _saveState();
  }

  void _playReading(int index) async {
    final reading = readings[index];

    // Nếu đang phát bài này, dừng
    if (_isPlaying && _currentPlayingIndex == index) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingIndex = null;
        _currentCharPosition = 0;
        _startOffsetForResume = 0;
      });
      await _saveState();
      return;
    }

    // Dừng bài khác nếu đang phát
    if (_isPlaying) {
      await _tts.stop();
    }

    // Phát bài mới từ đầu
    _startOffsetForResume = 0; // Reset offset cho bài mới
    await _tts.speak(reading.content);

    setState(() {
      _currentPlayingIndex = index;
      _isPlaying = true;
      _currentCharPosition = 0; // Bắt đầu từ đầu
    });

    await _saveState();
  }

  @override
  void dispose() {
    // Save state before dispose
    if (_isPlaying && _currentPlayingIndex != null) {
      _saveState();
      _tts.stop();
    }

    super.dispose();
  }

  // Helper function để parse số an toàn
  int? _safeParseInt(String value) {
    try {
      // Loại bỏ các ký tự không phải số
      final cleaned = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) return null;
      return int.parse(cleaned);
    } catch (e) {
      print('❌ Không thể parse "$value": $e');
      return null;
    }
  }

  String? _getReadingContent(String book, String chaptersRange) {
    // Mapping đầy đủ các tên sách viết tắt
    final bookMappings = {
      // Cựu Ước - Ngũ Thư
      'St': 'Sáng Thế Ký',
      'Xh': 'Xuất Hành',
      'Lv': 'Lê-vi',
      'Ds': 'Dân Số',
      'Dnl': 'Đệ Nhị Luật',

      // Cựu Ước - Lịch Sử
      'Gs': 'Giô-suê',
      'Tl': 'Thủ Lãnh',
      'Ru': 'Rút',
      '1Sm': 'Samuen 1',
      '2Sm': 'Samuen 2',
      '1 Sm': 'Samuen 1',
      '2 Sm': 'Samuen 2',
      '1Vua': 'Vua 1',
      '2Vua': 'Vua 2',
      '1 Vua': 'Vua 1',
      '2 Vua': 'Vua 2',
      '1Sb': 'Sử Biên 1',
      '2Sb': 'Sử Biên 2',
      '1 Sb': 'Sử Biên 1',
      '2 Sb': 'Sử Biên 2',
      'Ezr': 'Étra',
      'Neh': 'NơKhemia',
      'Tb': 'Tôbia',
      'Jdt': 'GiuDiTha',
      'Et': 'Étte',
      '1Mcb': '1 Mác-ca-bê',
      '2Mcb': '2 Mác-ca-bê',

      // Cựu Ước - Khôn Ngoan
      'Gb': 'Gióp',
      'Cn': 'Châm Ngôn',
      'Gv': 'Giảng Viên',
      'Dc': 'Diễm Ca',
      'Kn': 'Khôn Ngoan',
      'Hc': 'Huấn Ca',

      // Cựu Ước - Tiên Tri
      'Is': 'I-sai-a',
      'Gr': 'Giêrêmia',
      'Ae': 'Aica',
      'Ba': 'Ba-rúc',
      'Ed': 'Êdêkien',
      'Ez': 'Êdêkien',
      'Dn': 'Đanien',
      'Hs': 'Hôsê',
      'Jl': 'Giôen',
      'Am': 'A-mốt',
      'Ob': 'Ôvađia',
      'Gn': 'Giôna',
      'Mk': 'Mikha',
      'Na': 'Nakhum',
      'Ha': 'Khabarúc',
      'Xp': 'Xôphônia',
      'Ag': 'Khácgai',
      'Za': 'Dacaria',
      'Ml': 'Malakhi',

      // Tân Ước - Phúc Âm
      'Mt': 'Mátthêu',
      'Mc': 'Máccô',
      'Lc': 'Luca',
      'Ga': 'Gioan',

      // Tân Ước - Thư
      'Cv': 'Công Vụ Tông Đồ',
      'Rm': 'Thư Rôma',
      '1Cr': 'Thư Côrintô 1',
      '2Cr': 'Thư Côrintô 2',
      '1 Cr': 'Thư Côrintô 1',
      '2 Cr': 'Thư Côrintô 2',
      'Gl': 'Thư Galát',
      'Eph': 'Thư Êphêsô',
      'Pl': 'Thư Philípphê',
      'Cl': 'Thư Côlôxê',
      '1Tx': 'Thư Thêxalônica 1',
      '2Tx': 'Thư Thêxalônica 2',
      '1 Tx': 'Thư Thêxalônica 1',
      '2 Tx': 'Thư Thêxalônica 2',
      '1Tm': 'Thư Timôthê 1',
      '2Tm': 'Thư Timôthê 2',
      '1 Tm': 'Thư Timôthê 1',
      '2 Tm': 'Thư Timôthê 2',
      'Tt': 'Thư Titô',
      'Plm': 'Thư Philêmon',
      'Dt': 'Thư Do thái',
      'Gc': 'Thư Giacôbê',
      '1Pr': 'Thư Phêrô 1',
      '2Pr': 'Thư Phêrô 2',
      '1 Pr': 'Thư Phêrô 1',
      '2 Pr': 'Thư Phêrô 2',
      '1Ga': 'Thư Gioan 1',
      '2Ga': 'Thư Gioan 2',
      '3Ga': 'Thư Gioan 3',
      '1 Ga': 'Thư Gioan 1',
      '2 Ga': 'Thư Gioan 2',
      '3 Ga': 'Thư Gioan 3',
      'Gd': 'Thư Giuđa',
      'Kh': 'Khải Huyền',
    };

    // Tìm tên sách chính xác
    String cleanBook = book.trim().replaceAll(' ', '');
    String actualBookName =
        bookMappings[cleanBook] ?? bookMappings[book] ?? book;

    // Xác định sách thuộc Cựu Ước hay Tân Ước
    Map<String, dynamic>? bookData =
        cuuUoc![actualBookName] ?? tanUoc![actualBookName];

    if (bookData == null) {
      bookData = cuuUoc![book] ?? tanUoc![book];
    }

    if (bookData == null) {
      print(
          '❌ Không tìm thấy sách: $book (clean: $cleanBook, mapped: $actualBookName)');
      return null;
    }

    print('✅ Tìm thấy sách: $book -> $actualBookName');

    StringBuffer content = StringBuffer();

    // Parse chaptersRange để xử lý cả trường hợp: "4:6-8,16-18" hoặc "3:12-14,4:6-8"
    final parts = chaptersRange.split(',');

    // Nhóm các range theo chương
    Map<String, List<String>> chapterRanges = {};
    String? currentChapter;

    for (var part in parts) {
      part = part.trim();

      if (part.contains(':')) {
        // Có dạng "4:6-8" hoặc "4:6"
        final chapterPart = part.split(':')[0];
        currentChapter = chapterPart;

        if (!chapterRanges.containsKey(currentChapter)) {
          chapterRanges[currentChapter] = [];
        }
        chapterRanges[currentChapter]!.add(part.split(':')[1]);
      } else if (currentChapter != null) {
        // Không có dấu ":", nghĩa là cùng chương với phần trước
        // Ví dụ: "4:6-8,16-18" -> "16-18" thuộc chương 4
        chapterRanges[currentChapter]!.add(part);
      }
    }

    // Xử lý từng chương
    for (var entry in chapterRanges.entries) {
      final chapter = entry.key;
      final ranges = entry.value;

      final chapterData = bookData[chapter];
      if (chapterData == null) {
        print('❌ Không tìm thấy chương $chapter');
        continue;
      }

      // Xử lý từng range trong chương
      for (var range in ranges) {
        if (range.contains('-')) {
          // Range: "6-8" hoặc "16-18"
          final rangeParts = range.split('-');

          final startVerse = _safeParseInt(rangeParts[0]);
          final endVerse = _safeParseInt(rangeParts[1]);

          if (startVerse == null || endVerse == null) {
            print('❌ Lỗi range: $range');
            continue;
          }

          // Tiêu đề cho range
          content.writeln('\n$actualBookName $chapter:$startVerse-$endVerse\n');

          // Lấy các câu trong range
          for (int i = startVerse; i <= endVerse; i++) {
            final verse = chapterData[i.toString()];
            if (verse != null) {
              content.writeln('$i. $verse\n');
            }
          }
        } else {
          // Câu đơn: "6"
          final verse = _safeParseInt(range);

          if (verse == null) {
            print('❌ Lỗi verse: $range');
            continue;
          }

          final verseText = chapterData[verse.toString()];

          content.writeln('\n$actualBookName $chapter:$verse\n');
          if (verseText != null) {
            content.writeln('$verse. $verseText\n');
          }
        }
      }
    }

    return content.toString();
  }

  String _getDateString() {
    final dateParts = widget.date.split('-');
    final year = dateParts[0];
    final month = dateParts[1];
    final day = dateParts[2];

    final date = DateTime.parse(widget.date);
    final weekDays = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    final weekday = weekDays[date.weekday];

    return '$weekday, ngày $day tháng $month năm $year';
  }

  @override
  Widget build(BuildContext context) {
    final dayData = lichCongGiao?[widget.date];
    final saintName = dayData?['saintName'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getDateString(),
              style: const TextStyle(fontSize: 14),
            ),
            if (saintName.isNotEmpty)
              Text(
                saintName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải bài đọc...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadReadings,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : readings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Không có bài đọc cho ngày này',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: readings.length,
                      itemBuilder: (context, index) {
                        final reading = readings[index];
                        return _buildReadingCard(reading, index);
                      },
                    ),
    );
  }

  Widget _buildReadingCard(ReadingContent reading, int index) {
    IconData icon;
    Color color;
    String displayType = reading.type;

    if (reading.type.contains('Tin Mừng')) {
      icon = Icons.auto_stories;
      color = Colors.amber[700]!;
    } else if (reading.type.contains('Bài Đọc 1') ||
        reading.type.contains('Bài 1')) {
      icon = Icons.book;
      color = Colors.blue;
      displayType = 'Bài Đọc 1';
    } else if (reading.type.contains('Bài Đọc 2') ||
        reading.type.contains('Bài 2')) {
      icon = Icons.book;
      color = Colors.green;
      displayType = 'Bài Đọc 2';
    } else {
      icon = Icons.menu_book;
      color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: readingKeys.putIfAbsent(index, () => GlobalKey()),
          initiallyExpanded: _expandedIndex == index,
          onExpansionChanged: (bool expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          title: Text(
            displayType,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          subtitle: Text(
            '${reading.book} ${reading.chapters}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentPlayingIndex == index && _isPlaying)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              IconButton(
                icon: Icon(
                  _currentPlayingIndex == index && _isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: color,
                ),
                onPressed: () => _playReading(index),
              ),
            ],
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: color,
          collapsedIconColor: color,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildContentWithHighlight(reading.content, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWithHighlight(String content, int index) {
    // Nếu không phải bài đang phát, hiển thị bình thường
    if (_currentPlayingIndex != index || !_isPlaying) {
      return SelectableText(
        content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.8,
          letterSpacing: 0.3,
        ),
      );
    }

    // Highlight vị trí đang đọc
    if (_currentCharPosition >= 0 && _currentCharPosition < content.length) {
      final beforeText = content.substring(0, _currentCharPosition);
      final atPosition = content[_currentCharPosition];
      final afterText = content.substring(_currentCharPosition + 1);

      return SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: beforeText,
              style: const TextStyle(
                  fontSize: 15, height: 1.8, letterSpacing: 0.3),
            ),
            TextSpan(
              text: atPosition,
              style: const TextStyle(
                fontSize: 15,
                height: 1.8,
                letterSpacing: 0.3,
                backgroundColor: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: afterText,
              style: const TextStyle(
                  fontSize: 15, height: 1.8, letterSpacing: 0.3),
            ),
          ],
        ),
      );
    }

    return SelectableText(
      content,
      style: const TextStyle(
        fontSize: 15,
        height: 1.8,
        letterSpacing: 0.3,
      ),
    );
  }
}

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
}
