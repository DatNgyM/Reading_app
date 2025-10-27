import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(ReadingApp());
}

class ReadingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '📖 Bài Đọc Hàng Ngày',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? jsonData;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/lich_cong_giao_2025.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      setState(() {
        jsonData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Lỗi load dữ liệu: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic>? _getReadingForDate(DateTime date) {
    if (jsonData == null) return null;
    final dateKey = _formatDate(date);
    return jsonData![dateKey];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📖 Bài Đọc Hàng Ngày'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : jsonData == null
              ? Center(child: Text('Không thể load dữ liệu'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final reading = _getReadingForDate(selectedDate);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ngày: ${_formatDisplayDate(selectedDate)}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: Text('Chọn ngày'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          if (reading != null) ...[
            // Saint name
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🎭 ${reading['saintName']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 20),

            // Readings
            Text(
              '📚 Các Bài Đọc:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            ...(reading['readings'] as List<dynamic>)
                .map((readingItem) => _buildReadingCard(readingItem))
                .toList(),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có bài đọc cho ngày này'),
                ],
              ),
            ),
          ],

          SizedBox(height: 20),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _printTodayReading(),
                  icon: Icon(Icons.print),
                  label: Text('In Bài Đọc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showStats(),
                  icon: Icon(Icons.analytics),
                  label: Text('Thống Kê'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(Map<String, dynamic> readingItem) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getReadingIcon(readingItem['type']),
                  color: _getReadingColor(readingItem['type']),
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    readingItem['type'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getReadingColor(readingItem['type']),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '📖 ${readingItem['book']} ${readingItem['chapters']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '📄 File: ${readingItem['pdfFile']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getReadingIcon(String type) {
    if (type.contains('Tin Mừng')) return Icons.favorite;
    if (type.contains('Thi Đáp')) return Icons.music_note;
    if (type.contains('Bài Đọc')) return Icons.book;
    return Icons.article;
  }

  Color _getReadingColor(String type) {
    if (type.contains('Tin Mừng')) return Colors.red;
    if (type.contains('Thi Đáp')) return Colors.orange;
    if (type.contains('Bài Đọc')) return Colors.blue;
    return Colors.grey;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _printTodayReading() {
    final reading = _getReadingForDate(selectedDate);
    if (reading != null) {
      print('\n📖 BÀI ĐỌC NGÀY ${_formatDisplayDate(selectedDate)}');
      print('🎭 ${reading['saintName']}');
      print('─' * 50);

      for (var readingItem in reading['readings']) {
        print(
            '📚 ${readingItem['type']}: ${readingItem['book']} ${readingItem['chapters']}');
        print('   📄 File: ${readingItem['pdfFile']}');
      }
      print('─' * 50);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Đã in bài đọc vào console')),
      );
    }
  }

  void _showStats() {
    if (jsonData == null) return;

    Map<String, int> stats = {};
    for (var dateData in jsonData!.values) {
      final readings = dateData['readings'] as List<dynamic>;
      for (var reading in readings) {
        final book = reading['book'] as String;
        stats[book] = (stats[book] ?? 0) + 1;
      }
    }

    final sortedStats = Map.fromEntries(
        stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📊 Thống Kê Bài Đọc'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortedStats.entries
                .take(15)
                .map((entry) => ListTile(
                      title: Text(entry.key),
                      trailing: Text('${entry.value} lần'),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
