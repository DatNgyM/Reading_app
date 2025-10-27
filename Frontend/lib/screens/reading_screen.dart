import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../services/bible_pdf_service.dart';

class ReadingScreen extends StatefulWidget {
  final String bookCode;
  final BibleBookInfo bookInfo;
  final String pdfFile;
  final int? initialChapter;

  const ReadingScreen({
    Key? key,
    required this.bookCode,
    required this.bookInfo,
    required this.pdfFile,
    this.initialChapter,
  }) : super(key: key);

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  String? pdfPath;
  bool isLoading = true;
  int currentChapter = 1;
  int? currentPage;

  @override
  void initState() {
    super.initState();
    currentChapter = widget.initialChapter ?? 1;
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() => isLoading = true);

    try {
      final path = await BiblePdfService.copyPdfToLocal(widget.pdfFile);
      setState(() {
        pdfPath = path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải PDF: $e')),
        );
      }
    }
  }

  int _getPageForChapter(int chapter) {
    // Sử dụng logic tính toán từ BiblePdfService để đảm bảo tính nhất quán
    return BiblePdfService.getPageNumber(widget.bookCode, chapter.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bookInfo.fullName,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Chương $currentChapter',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showChapterList,
            tooltip: 'Danh sách chương',
          ),
        ],
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
          : pdfPath == null
              ? const Center(child: Text('Không thể tải PDF'))
              : PDFView(
                  filePath: pdfPath!,
                  defaultPage: _getPageForChapter(currentChapter),
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  onPageChanged: (page, total) {
                    if (page != null) {
                      setState(() => currentPage = page);

                      // Tính chương dựa trên trang
                      final chapter =
                          ((page - widget.bookInfo.startPage) / 2).ceil() + 1;
                      if (chapter != currentChapter &&
                          chapter > 0 &&
                          chapter <= widget.bookInfo.totalChapters) {
                        setState(() => currentChapter = chapter);
                      }
                    }
                  },
                  onError: (error) {
                    print('PDF Error: $error');
                  },
                ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentChapter > 1
                    ? () {
                        setState(() => currentChapter--);
                        _loadPdf();
                      }
                    : null,
                tooltip: 'Chương trước',
              ),
              Text(
                'Chương $currentChapter / ${widget.bookInfo.totalChapters}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentChapter < widget.bookInfo.totalChapters
                    ? () {
                        setState(() => currentChapter++);
                        _loadPdf();
                      }
                    : null,
                tooltip: 'Chương sau',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chọn chương',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.bookInfo.fullName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: widget.bookInfo.totalChapters,
                itemBuilder: (context, index) {
                  final chapter = index + 1;
                  final isSelected = chapter == currentChapter;

                  return InkWell(
                    onTap: () {
                      setState(() => currentChapter = chapter);
                      Navigator.pop(context);
                      _loadPdf();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.red[700]!
// Dart code
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$chapter',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
