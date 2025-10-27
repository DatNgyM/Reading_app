import 'package:flutter/material.dart';
import 'package:reading_app/services/json_liturgical_service.dart';
import 'package:reading_app/services/bible_pdf_service.dart';

class DailyReadingDemo extends StatefulWidget {
  @override
  _DailyReadingDemoState createState() => _DailyReadingDemoState();
}

class _DailyReadingDemoState extends State<DailyReadingDemo> {
  DailyReading? todayReading;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayReading();
  }

  Future<void> _loadTodayReading() async {
    try {
      final reading = await JsonLiturgicalService.getTodayReading();
      setState(() {
        todayReading = reading;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading reading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📖 Bài Đọc Hàng Ngày'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : todayReading == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Không có bài đọc cho hôm nay'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '📅 ${_formatDate(todayReading!.date)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '🎭 ${todayReading!.saintName}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                      
                      ...todayReading!.readings.map((reading) => 
                        _buildReadingCard(reading)
                      ).toList(),
                      
                      SizedBox(height: 20),
                      
                      // Actions
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
                ),
    );
  }

  Widget _buildReadingCard(ReadingReference reading) {
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
                  _getReadingIcon(reading.type),
                  color: _getReadingColor(reading.type),
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reading.type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getReadingColor(reading.type),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '📖 ${reading.book} ${reading.chapters}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '📄 File: ${reading.pdfFile}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _openReading(reading),
              child: Text('Đọc Ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _printTodayReading() async {
    await JsonLiturgicalService.printTodayReading();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Đã in bài đọc hôm nay')),
    );
  }

  void _showStats() async {
    final stats = await JsonLiturgicalService.getReadingStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📊 Thống Kê Bài Đọc'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: stats.entries
                .take(10)
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

  void _openReading(ReadingReference reading) {
    // Tính toán trang PDF
    final pageNumber = BiblePdfService.getPageNumber(reading.book, reading.chapters);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📖 ${reading.type}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sách: ${reading.book}'),
            Text('Chương: ${reading.chapters}'),
            Text('File PDF: ${reading.pdfFile}'),
            Text('Trang: $pageNumber'),
          ],
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
