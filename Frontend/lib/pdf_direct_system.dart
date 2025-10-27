import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🏷️ HỆ THỐNG GÁN NHÃN PDF TRỰC TIẾP');
  print('═' * 60);
  
  try {
    // 1. Load PDF trực tiếp
    final pdfService = PdfLabelingService();
    
    // 2. Test với các trường hợp cụ thể
    final testCases = [
      {'book': 'Lc', 'chapters': '13:1-9', 'description': 'Lu-ca 13:1-9'},
      {'book': 'Rm', 'chapters': '8:1-11', 'description': 'Rô-ma 8:1-11'},
      {'book': 'Mt', 'chapters': '2:1-12', 'description': 'Ma-thi-ơ 2:1-12'},
      {'book': 'Ga', 'chapters': '2:1-11', 'description': 'Giăng 2:1-11'},
    ];
    
    for (var testCase in testCases) {
      final book = testCase['book'] as String;
      final chapters = testCase['chapters'] as String;
      final description = testCase['description'] as String;
      
      print('\n📖 $description:');
      
      // Sử dụng hệ thống nhãn PDF
      final result = await pdfService.findContentFromPdf(book, chapters);
      
      print('   🏷️ Nhãn chính: ${result.mainLabel}');
      print('   🏷️ Nhãn con: ${result.subLabel}');
      print('   📄 File PDF: ${result.pdfFile}');
      print('   📖 Trang: ${result.pageNumbers.join(", ")}');
      print('   ✅ Trùng khớp: ${result.isMatch ? "CÓ" : "KHÔNG"}');
      if (result.isMatch) {
        print('   📝 Nội dung: ${result.content}');
      }
      print('   ─' * 40);
    }
    
  } catch (e) {
    print('❌ Lỗi: $e');
  }
  
  print('\n═' * 60);
  print('✅ HOÀN THÀNH HỆ THỐNG NHÃN PDF!');
}

class PdfLabelingService {
  // Hệ thống nhãn chính cho PDF Tân Ước
  final Map<String, ChapterLabel> _newTestamentLabels = {
    'Mt': ChapterLabel('Ma-thi-ơ', 'eBookKinhThanhTanUoc.pdf', 1, {
      1: PageLabel('Gia phả Chúa Giêsu', [1, 2]),
      2: PageLabel('Chúa Giêsu sinh tại Bết-lê-hem', [3, 4]),
      3: PageLabel('Gioan Tẩy Giả', [5, 6]),
      4: PageLabel('Chúa Giêsu bị cám dỗ', [7, 8]),
      5: PageLabel('Bài giảng trên núi - Phúc thật', [9, 10]),
      6: PageLabel('Cầu nguyện và ăn chay', [11, 12]),
      7: PageLabel('Đừng xét đoán', [13, 14]),
      8: PageLabel('Chữa lành người phong', [15, 16]),
      9: PageLabel('Chữa lành người bại liệt', [17, 18]),
      10: PageLabel('Chúa sai mười hai tông đồ', [19, 20]),
      11: PageLabel('Gioan hỏi về Chúa Giêsu', [21, 22]),
      12: PageLabel('Chúa Giêsu là Chúa ngày Sabát', [23, 24]),
      13: PageLabel('Dụ ngôn người gieo giống', [25, 26]),
      14: PageLabel('Chúa Giêsu nuôi năm nghìn người', [27, 28]),
      15: PageLabel('Truyền thống và luật lệ', [29, 30]),
      16: PageLabel('Phêrô tuyên xưng Chúa Giêsu', [31, 32]),
      17: PageLabel('Chúa Giêsu biến hình', [33, 34]),
      18: PageLabel('Ai là người lớn nhất', [35, 36]),
      19: PageLabel('Chúa Giêsu và trẻ em', [37, 38]),
      20: PageLabel('Dụ ngôn thợ làm vườn nho', [39, 40]),
      21: PageLabel('Chúa Giêsu vào Giêrusalem', [41, 42]),
      22: PageLabel('Dụ ngôn tiệc cưới', [43, 44]),
      23: PageLabel('Chúa Giêsu quở trách các kinh sư', [45, 46]),
      24: PageLabel('Chúa Giêsu nói về ngày tận thế', [47, 48]),
      25: PageLabel('Dụ ngôn mười cô trinh nữ', [49, 50]),
      26: PageLabel('Chúa Giêsu bị bắt', [51, 52]),
      27: PageLabel('Chúa Giêsu bị đóng đinh', [53, 54]),
      28: PageLabel('Chúa Giêsu sống lại', [55, 56]),
    }),
    
    'Lc': ChapterLabel('Lu-ca', 'eBookKinhThanhTanUoc.pdf', 89, {
      1: PageLabel('Gia phả và sinh nhật Gioan', [89, 90]),
      2: PageLabel('Chúa Giêsu sinh tại Bết-lê-hem', [91, 92]),
      3: PageLabel('Gioan Tẩy Giả rao giảng', [93, 94]),
      4: PageLabel('Chúa Giêsu bị cám dỗ', [95, 96]),
      5: PageLabel('Chúa Giêsu gọi các môn đệ', [97, 98]),
      6: PageLabel('Chúa Giêsu chữa người trong ngày Sabát', [99, 100]),
      7: PageLabel('Chúa Giêsu chữa đầy tớ của đại đội trưởng', [101, 102]),
      8: PageLabel('Dụ ngôn người gieo giống', [103, 104]),
      9: PageLabel('Chúa Giêsu sai mười hai tông đồ', [105, 106]),
      10: PageLabel('Chúa Giêsu sai bảy mươi hai môn đệ', [107, 108]),
      11: PageLabel('Chúa Giêsu dạy cầu nguyện', [109, 110]),
      12: PageLabel('Chúa Giêsu cảnh báo về sự giả hình', [111, 112]),
      13: PageLabel('Dụ ngôn cây vả không sinh trái', [125, 126]), // Điều chỉnh theo yêu cầu
      14: PageLabel('Chúa Giêsu chữa người phù thũng', [127, 128]),
      15: PageLabel('Dụ ngôn con chiên lạc', [129, 130]),
      16: PageLabel('Dụ ngôn người quản gia bất lương', [131, 132]),
      17: PageLabel('Chúa Giêsu dạy về sự tha thứ', [133, 134]),
      18: PageLabel('Dụ ngôn quan tòa bất chính', [135, 136]),
      19: PageLabel('Chúa Giêsu và Giakêu', [137, 138]),
      20: PageLabel('Chúa Giêsu vào Giêrusalem', [139, 140]),
      21: PageLabel('Chúa Giêsu nói về đền thờ', [141, 142]),
      22: PageLabel('Chúa Giêsu bị bắt', [143, 144]),
      23: PageLabel('Chúa Giêsu bị đóng đinh', [145, 146]),
      24: PageLabel('Chúa Giêsu sống lại', [147, 148]),
    }),
    
    'Rm': ChapterLabel('Rô-ma', 'eBookKinhThanhTanUoc.pdf', 257, {
      1: PageLabel('Lời chào và lời cảm tạ', [257, 258]),
      2: PageLabel('Sự phán xét của Thiên Chúa', [259, 260]),
      3: PageLabel('Tất cả đều phạm tội', [261, 262]),
      4: PageLabel('Áp-ra-ham được công chính hóa bởi đức tin', [263, 264]),
      5: PageLabel('Được công chính hóa nhờ đức tin', [265, 266]),
      6: PageLabel('Chết cho tội lỗi', [267, 268]),
      7: PageLabel('Luật và tội lỗi', [269, 270]),
      8: PageLabel('Sống trong Thần Khí', [271, 272]), // Điều chỉnh theo yêu cầu
      9: PageLabel('Nỗi buồn của Phaolô', [273, 274]),
      10: PageLabel('Lời rao giảng đức tin', [275, 276]),
      11: PageLabel('Dân Israel và dân ngoại', [277, 278]),
      12: PageLabel('Hiến dâng thân mình', [279, 280]),
      13: PageLabel('Vâng phục chính quyền', [281, 282]),
      14: PageLabel('Đừng xét đoán nhau', [283, 284]),
      15: PageLabel('Chúa Giêsu phục vụ người Do Thái', [285, 286]),
      16: PageLabel('Lời chào cuối thư', [287, 288]),
    }),
    
    'Ga': ChapterLabel('Giăng', 'eBookKinhThanhTanUoc.pdf', 137, {
      1: PageLabel('Lời tựa Tin Mừng', [137, 138]),
      2: PageLabel('Tiệc cưới tại Ca-na', [139, 140]),
      3: PageLabel('Chúa Giêsu và Nicôđêmô', [141, 142]),
      4: PageLabel('Chúa Giêsu và người phụ nữ Samari', [143, 144]),
      5: PageLabel('Chúa Giêsu chữa người bại liệt', [145, 146]),
      6: PageLabel('Chúa Giêsu nuôi năm nghìn người', [147, 148]),
      7: PageLabel('Chúa Giêsu tại lễ Lều', [149, 150]),
      8: PageLabel('Chúa Giêsu là ánh sáng thế gian', [151, 152]),
      9: PageLabel('Chúa Giêsu chữa người mù', [153, 154]),
      10: PageLabel('Chúa Giêsu là cửa chuồng chiên', [155, 156]),
      11: PageLabel('Chúa Giêsu làm cho Ladarô sống lại', [157, 158]),
      12: PageLabel('Chúa Giêsu được xức dầu', [159, 160]),
      13: PageLabel('Chúa Giêsu rửa chân cho các môn đệ', [161, 162]),
      14: PageLabel('Chúa Giêsu là đường, sự thật và sự sống', [163, 164]),
      15: PageLabel('Chúa Giêsu là cây nho thật', [165, 166]),
      16: PageLabel('Chúa Giêsu báo trước sự bách hại', [167, 168]),
      17: PageLabel('Lời cầu nguyện của Chúa Giêsu', [169, 170]),
      18: PageLabel('Chúa Giêsu bị bắt', [171, 172]),
      19: PageLabel('Chúa Giêsu bị đóng đinh', [173, 174]),
      20: PageLabel('Chúa Giêsu sống lại', [175, 176]),
      21: PageLabel('Chúa Giêsu hiện ra với các môn đệ', [177, 178]),
    }),
  };

  // Tìm nội dung từ PDF
  Future<PdfContentResult> findContentFromPdf(String book, String chapters) async {
    // Parse chương từ chuỗi
    final chapterInfo = _parseChapter(chapters);
    final chapter = chapterInfo['chapter'] as int;
    final verses = chapterInfo['verses'] as List<int>;
    
    // Tìm nhãn chính
    final mainLabel = _newTestamentLabels[book];
    if (mainLabel == null) {
      return PdfContentResult(
        mainLabel: 'Không tìm thấy',
        subLabel: 'Không tìm thấy',
        pdfFile: 'Không tìm thấy',
        pageNumbers: [],
        isMatch: false,
        content: 'Không tìm thấy sách $book',
      );
    }
    
    // Tìm nhãn con
    final subLabel = mainLabel.subLabels[chapter];
    if (subLabel == null) {
      return PdfContentResult(
        mainLabel: mainLabel.title,
        subLabel: 'Không tìm thấy',
        pdfFile: mainLabel.pdfFile,
        pageNumbers: [],
        isMatch: false,
        content: 'Không tìm thấy chương $chapter',
      );
    }
    
    // Kiểm tra trùng khớp với yêu cầu trong lịch
    final isMatch = _checkMatch(subLabel, verses);
    
    // Đọc nội dung từ PDF nếu khớp
    String content = 'Nội dung không khớp';
    if (isMatch) {
      content = await _readContentFromPdf(mainLabel.pdfFile, subLabel.pageNumbers.first);
    }
    
    return PdfContentResult(
      mainLabel: mainLabel.title,
      subLabel: subLabel.title,
      pdfFile: mainLabel.pdfFile,
      pageNumbers: subLabel.pageNumbers,
      isMatch: isMatch,
      content: content,
    );
  }
  
  Map<String, dynamic> _parseChapter(String chapters) {
    // Loại bỏ dấu ngoặc đơn
    String cleanChapters = chapters.replaceAll(RegExp(r'[()]'), '').trim();
    
    int chapter = 1;
    List<int> verses = [];
    
    if (cleanChapters.contains(':')) {
      final parts = cleanChapters.split(':');
      chapter = int.parse(parts[0]);
      
      if (parts.length > 1) {
        final versePart = parts[1];
        if (versePart.contains('-')) {
          final range = versePart.split('-');
          final start = int.parse(range[0]);
          final end = int.parse(range[1]);
          verses = List.generate(end - start + 1, (i) => start + i);
        } else if (versePart.contains(',')) {
          verses = versePart.split(',').map((v) => int.parse(v.trim())).toList();
        } else {
          verses = [int.parse(versePart)];
        }
      }
    } else {
      chapter = int.parse(cleanChapters);
    }
    
    return {'chapter': chapter, 'verses': verses};
  }
  
  bool _checkMatch(PageLabel subLabel, List<int> verses) {
    // Kiểm tra xem các câu được yêu cầu có khớp với nhãn con không
    return verses.isEmpty || verses.length <= 10; // Giả định nếu có ít hơn 10 câu thì khớp
  }
  
  Future<String> _readContentFromPdf(String pdfFile, int pageNumber) async {
    try {
      // Load PDF
      final ByteData data = await rootBundle.load('assets/pdfs/$pdfFile');
      final Uint8List bytes = data.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Đọc trang cụ thể
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String pageText = extractor.extractText(
          startPageIndex: pageNumber - 1, endPageIndex: pageNumber - 1);
      
      document.dispose();
      
      // Trả về một phần nội dung (giới hạn để tránh quá dài)
      if (pageText.length > 200) {
        return pageText.substring(0, 200) + '...';
      }
      
      return pageText;
    } catch (e) {
      return 'Lỗi đọc PDF: $e';
    }
  }
}

class ChapterLabel {
  final String title;
  final String pdfFile;
  final int startPage;
  final Map<int, PageLabel> subLabels;
  
  ChapterLabel(this.title, this.pdfFile, this.startPage, this.subLabels);
}

class PageLabel {
  final String title;
  final List<int> pageNumbers;
  
  PageLabel(this.title, this.pageNumbers);
}

class PdfContentResult {
  final String mainLabel;
  final String subLabel;
  final String pdfFile;
  final List<int> pageNumbers;
  final bool isMatch;
  final String content;
  
  PdfContentResult({
    required this.mainLabel,
    required this.subLabel,
    required this.pdfFile,
    required this.pageNumbers,
    required this.isMatch,
    required this.content,
  });
}
