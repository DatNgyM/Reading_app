import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/daily_reading.dart';
import '../services/bible_pdf_service.dart';

class DailyReadingScreen extends StatefulWidget {
  final ReadingReference reading;

  const DailyReadingScreen({
    Key? key,
    required this.reading,
  }) : super(key: key);

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  String? pdfPath;
  int initialPage = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() => isLoading = true);

      // Lấy số trang
      final page = BiblePdfService.getPageNumber(
        widget.reading.book,
        widget.reading.chapters,
      );

      // Copy PDF từ assets
      final path = await BiblePdfService.copyPdfToLocal(widget.reading.pdfFile);

      setState(() {
        pdfPath = path;
        initialPage = page;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.reading.type, style: const TextStyle(fontSize: 16)),
            Text(
              widget.reading.fullReference,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
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
                  Text('Đang tải Kinh Thánh...'),
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
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPdf,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : PDFView(
                  filePath: pdfPath!,
                  defaultPage: initialPage,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  onError: (error) {
                    setState(() {
                      errorMessage = 'Lỗi hiển thị PDF: $error';
                    });
                  },
                ),
    );
  }
}
