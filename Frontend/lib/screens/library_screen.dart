import 'package:flutter/material.dart';
import '../services/bible_pdf_service.dart';
import 'reading_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách sách từ BiblePdfService
    final oldTestamentBooks = BiblePdfService.getOldTestamentBooks();
    final newTestamentBooks = BiblePdfService.getNewTestamentBooks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư Viện Kinh Thánh'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Header Cựu Ước
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.book, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'CỰU ƯỚC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách sách Cựu Ước
          ...oldTestamentBooks.entries.map((entry) {
            return _buildBookCard(
              context,
              entry.key,
              entry.value,
              'eBookKinhThanhCuuUoc.pdf',
              Colors.blue,
            );
          }).toList(),

          const SizedBox(height: 24),

          // Header Tân Ước
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.menu_book, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'TÂN ƯỚC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách sách Tân Ước
          ...newTestamentBooks.entries.map((entry) {
            return _buildBookCard(
              context,
              entry.key,
              entry.value,
              'eBookKinhThanhTanUoc.pdf',
              Colors.green,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    String bookCode,
    BibleBookInfo bookInfo,
    String pdfFile,
    MaterialColor color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color[100],
          child: Icon(Icons.book_outlined, color: color[700]),
        ),
        title: Text(
          bookInfo.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$bookCode • ${bookInfo.totalChapters} chương',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingScreen(
                bookCode: bookCode,
                bookInfo: bookInfo,
                pdfFile: pdfFile,
              ),
            ),
          );
        },
      ),
    );
  }
}
