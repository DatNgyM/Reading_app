import '../models/reading_item.dart';
import '../models/notification_item.dart';

class SampleData {
  static List<ReadingItem> getTodayReadings() {
    return [
      ReadingItem(
        id: '1',
        title: 'Kinh Pháp Cú - Chương 1: Tâm',
        content: '''
Pháp cú là một trong những bộ kinh quan trọng nhất của Phật giáo, chứa đựng những lời dạy sâu sắc về đạo đức và trí tuệ. Chương đầu tiên nói về tâm thức và cách thức kiểm soát tâm trí.

"Tâm dẫn đầu các pháp, tâm làm chủ, tâm tạo tác. Nếu nói hoặc làm với tâm ô nhiễm, thì khổ đau sẽ theo sau như bánh xe theo chân con bò kéo xe."

Đây là một bài học quan trọng về việc kiểm soát tâm trí và nhận thức về tác động của suy nghĩ đến cuộc sống của chúng ta. Khi chúng ta có những suy nghĩ tích cực và trong sạch, cuộc sống sẽ trở nên tốt đẹp hơn.

Trong cuộc sống hàng ngày, chúng ta thường bị chi phối bởi những cảm xúc và suy nghĩ tiêu cực. Kinh Pháp Cú dạy chúng ta cách nhận biết và chuyển hóa những suy nghĩ này thành năng lượng tích cực.

Thiền định là một phương pháp hiệu quả để rèn luyện tâm trí. Thông qua việc ngồi thiền, chúng ta có thể quan sát và hiểu rõ hơn về bản chất của tâm trí mình.

Khi chúng ta học được cách kiểm soát tâm trí, chúng ta sẽ có thể đối mặt với mọi khó khăn trong cuộc sống một cách bình tĩnh và sáng suốt hơn.

Thực hành chánh niệm là chìa khóa để phát triển sự hiểu biết về tâm trí. Chúng ta cần học cách quan sát những suy nghĩ của mình mà không bị chúng chi phối.

Sự giác ngộ không phải là việc loại bỏ hoàn toàn những suy nghĩ, mà là học cách sống hài hòa với chúng và không để chúng kiểm soát cuộc sống của chúng ta.
        ''',
        author: 'Đức Phật Thích Ca',
        date: DateTime.now(),
        category: 'Phật giáo',
        readingTime: 15,
        difficulty: 'Medium',
        tags: ['thiền định', 'tâm trí', 'đạo đức', 'chánh niệm'],
        description:
            'Khám phá bản chất của tâm trí và cách thức kiểm soát suy nghĩ theo lời dạy của Đức Phật.',
        rating: 4.8,
        viewCount: 1250,
        progress: 0.0,
      ),
      ReadingItem(
        id: '2',
        title: 'Đạo Đức Kinh - Chương 1: Đạo',
        content: '''
Đạo Đức Kinh là tác phẩm kinh điển của Lão Tử, được coi là nền tảng của Đạo giáo. Chương đầu tiên nói về bản chất của Đạo và cách thức nhận biết nó.

"Đạo khả đạo, phi thường đạo. Danh khả danh, phi thường danh."

Đạo là nguyên lý cơ bản của vũ trụ, là nguồn gốc của mọi sự vật. Tuy nhiên, Đạo không thể được mô tả bằng ngôn từ thông thường, vì nó vượt ra ngoài khả năng hiểu biết của con người.

Lão Tử dạy chúng ta rằng để hiểu được Đạo, chúng ta cần phải từ bỏ những khái niệm và định kiến của mình. Chỉ khi nào tâm trí trở nên trong sạch và không còn bị chi phối bởi những suy nghĩ phức tạp, chúng ta mới có thể cảm nhận được sự hiện diện của Đạo.

Trong cuộc sống hiện đại, chúng ta thường bị cuốn vào những hoạt động phức tạp và những mối quan tâm không cần thiết. Đạo Đức Kinh nhắc nhở chúng ta về tầm quan trọng của sự đơn giản và tự nhiên.

Khi chúng ta học được cách sống theo Đạo, chúng ta sẽ cảm thấy hài hòa với thiên nhiên và với chính bản thân mình. Điều này sẽ mang lại cho chúng ta sự bình an và hạnh phúc thực sự.

Đạo không phải là một khái niệm trừu tượng mà là một thực tại sống động mà chúng ta có thể cảm nhận trong mọi khoảnh khắc của cuộc sống.

Sự hiểu biết về Đạo không đến từ việc tích lũy kiến thức mà từ việc buông bỏ những gì chúng ta nghĩ là mình biết.
        ''',
        author: 'Lão Tử',
        date: DateTime.now(),
        category: 'Đạo giáo',
        readingTime: 20,
        difficulty: 'Hard',
        tags: ['triết học', 'đạo', 'tự nhiên', 'đơn giản'],
        description:
            'Tìm hiểu về bản chất của Đạo và cách thức sống hài hòa với tự nhiên.',
        rating: 4.6,
        viewCount: 890,
        progress: 0.0,
      ),
      ReadingItem(
        id: '3',
        title: 'Thiền và Cuộc Sống Hiện Đại',
        content: '''
Thiền định không chỉ là một phương pháp tu tập mà còn là một nghệ thuật sống. Trong thời đại hiện đại với nhịp sống nhanh chóng, thiền định trở thành một công cụ quan trọng để tìm lại sự cân bằng và bình an trong tâm hồn.

Thiền định giúp chúng ta:
- Giảm stress và lo âu
- Tăng cường khả năng tập trung
- Phát triển sự tự nhận thức
- Cải thiện chất lượng giấc ngủ
- Tăng cường hệ miễn dịch

Có nhiều hình thức thiền định khác nhau, từ thiền chánh niệm đến thiền từ bi, mỗi loại đều có những lợi ích riêng biệt.

Thiền chánh niệm tập trung vào việc quan sát hơi thở và những cảm giác trong cơ thể, giúp chúng ta sống trong hiện tại.

Thiền từ bi phát triển lòng từ bi và sự thấu hiểu đối với bản thân và người khác.

Để bắt đầu thiền định, bạn chỉ cần dành ra 10-15 phút mỗi ngày trong một không gian yên tĩnh.

Hãy nhớ rằng thiền định không phải là việc ngừng suy nghĩ mà là học cách quan sát suy nghĩ mà không bị chúng chi phối.
        ''',
        author: 'Thiền sư Thích Nhất Hạnh',
        date: DateTime.now(),
        category: 'Thiền định',
        readingTime: 12,
        difficulty: 'Easy',
        tags: ['thiền', 'chánh niệm', 'stress', 'bình an'],
        description:
            'Hướng dẫn thiền định cho người mới bắt đầu trong cuộc sống hiện đại.',
        rating: 4.9,
        viewCount: 2100,
        progress: 0.0,
      ),
    ];
  }

  static List<ReadingItem> getRecommendedReadings() {
    return [
      ReadingItem(
        id: '4',
        title: 'Triết Học Phương Đông',
        content:
            'Khám phá các trường phái triết học phương Đông và ảnh hưởng của chúng đến cuộc sống hiện đại...',
        author: 'Giáo sư Nguyễn Văn A',
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Triết học',
        readingTime: 30,
        difficulty: 'Medium',
        tags: ['triết học', 'phương đông', 'lịch sử'],
        description: 'Tổng quan về các trường phái triết học phương Đông.',
        rating: 4.5,
        viewCount: 1560,
        progress: 0.0,
      ),
      ReadingItem(
        id: '5',
        title: 'Lịch Sử Phật Giáo Việt Nam',
        content:
            'Tìm hiểu về lịch sử phát triển của Phật giáo tại Việt Nam từ thời kỳ đầu đến hiện tại...',
        author: 'Tiến sĩ Lê Văn B',
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Lịch sử',
        readingTime: 35,
        difficulty: 'Medium',
        tags: ['phật giáo', 'việt nam', 'lịch sử'],
        description: 'Lịch sử phát triển Phật giáo tại Việt Nam.',
        rating: 4.7,
        viewCount: 980,
        progress: 0.0,
      ),
      ReadingItem(
        id: '6',
        title: 'Kinh Kim Cang',
        content:
            'Một trong những bộ kinh quan trọng nhất của Phật giáo Đại thừa, nói về tính không và trí tuệ Bát-nhã...',
        author: 'Đức Phật Thích Ca',
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Phật giáo',
        readingTime: 40,
        difficulty: 'Hard',
        tags: ['kim cang', 'bát-nhã', 'tính không'],
        description: 'Kinh Kim Cang - Bộ kinh về trí tuệ Bát-nhã.',
        rating: 4.8,
        viewCount: 1340,
        progress: 0.0,
      ),
    ];
  }

  static List<ReadingItem> getAllReadings() {
    return [
      ...getTodayReadings(),
      ...getRecommendedReadings(),
      ReadingItem(
        id: '7',
        title: 'Trang Tử Nam Hoa Kinh',
        content:
            'Tác phẩm triết học nổi tiếng của Trang Tử, chứa đựng những câu chuyện ngụ ngôn sâu sắc...',
        author: 'Trang Tử',
        date: DateTime.now().subtract(const Duration(days: 4)),
        category: 'Đạo giáo',
        readingTime: 45,
        difficulty: 'Hard',
        tags: ['trang tử', 'ngụ ngôn', 'triết học'],
        description: 'Nam Hoa Kinh - Tác phẩm triết học của Trang Tử.',
        rating: 4.6,
        viewCount: 720,
        progress: 0.0,
      ),
      ReadingItem(
        id: '8',
        title: 'Thiền Sư và Cuộc Đời',
        content:
            'Những câu chuyện về cuộc đời và sự giác ngộ của các thiền sư nổi tiếng...',
        author: 'Thiền sư Minh Đức',
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Thiền định',
        readingTime: 25,
        difficulty: 'Medium',
        tags: ['thiền sư', 'giác ngộ', 'câu chuyện'],
        description: 'Những câu chuyện về các thiền sư và hành trình giác ngộ.',
        rating: 4.7,
        viewCount: 1100,
        progress: 0.0,
      ),
    ];
  }

  static List<NotificationItem> getNotifications() {
    return [
      NotificationItem(
        id: '1',
        title: 'Nhắc nhở đọc sách',
        message:
            'Đã đến giờ đọc sách hàng ngày của bạn. Hãy dành 15 phút để đọc một bài học mới.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'reading_reminder',
        metadata: {'readingId': '1'},
      ),
      NotificationItem(
        id: '2',
        title: 'Thành tích mới',
        message:
            'Chúc mừng! Bạn đã hoàn thành 7 ngày đọc liên tiếp. Hãy tiếp tục duy trì thói quen tốt này.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        type: 'achievement',
        metadata: {'streak': 7},
      ),
      NotificationItem(
        id: '3',
        title: 'Cập nhật ứng dụng',
        message:
            'Phiên bản mới với nhiều tính năng hấp dẫn đã có sẵn. Cập nhật ngay để trải nghiệm tốt hơn.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        type: 'update',
        metadata: {'version': '1.1.0'},
      ),
      NotificationItem(
        id: '4',
        title: 'Bài đọc mới',
        message:
            'Có 3 bài đọc mới về Phật giáo đã được thêm vào thư viện. Hãy khám phá ngay.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        type: 'new_content',
        metadata: {'category': 'Phật giáo', 'count': 3},
      ),
      NotificationItem(
        id: '5',
        title: 'Lời nhắc nhở từ thiền sư',
        message:
            'Hôm nay hãy dành 10 phút để thiền định và tìm lại sự bình an trong tâm hồn.',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        type: 'reading_reminder',
        metadata: {'type': 'meditation'},
      ),
    ];
  }

  static List<String> getSearchSuggestions() {
    return [
      'Kinh Pháp Cú',
      'Đạo Đức Kinh',
      'Thiền định',
      'Phật giáo',
      'Đạo giáo',
      'Chánh niệm',
      'Tâm trí',
      'Bình an',
      'Giác ngộ',
      'Từ bi',
    ];
  }

  static List<String> getCategories() {
    return [
      'Tất cả',
      'Phật giáo',
      'Đạo giáo',
      'Thiền định',
      'Triết học',
      'Lịch sử',
    ];
  }

  static List<String> getDifficulties() {
    return [
      'Tất cả',
      'Easy',
      'Medium',
      'Hard',
    ];
  }
}
