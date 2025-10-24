import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/reading_card.dart';
import '../widgets/animated_widgets.dart';
import '../data/sample_data.dart';
import '../models/reading_item.dart';
import '../utils/app_theme.dart';
import 'reading_screen.dart';

class DailyReadingScreen extends StatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<ReadingItem> _dailyReadings = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadDailyReadings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyReadings() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate getting daily readings based on date
    final allReadings = SampleData.getAllReadings();
    setState(() {
      _dailyReadings = allReadings.take(3).toList(); // Get 3 readings for today
      _isLoading = false;
    });

    _animationController.forward();
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chọn ngày',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today_rounded),
                onPressed: _showDatePicker,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryLight.withOpacity(0.1),
                  AppTheme.secondaryLight.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryLight.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'vi')
                            .format(_selectedDate),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Bài đọc hôm nay',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_dailyReadings.length} bài',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuote() {
    final quotes = [
      "Hôm nay là một ngày mới, hãy bắt đầu với một bài đọc ý nghĩa.",
      "Đọc sách là cách tốt nhất để nuôi dưỡng tâm hồn.",
      "Mỗi trang sách là một bước tiến trên con đường trí tuệ.",
      "Kiến thức từ sách sẽ là người bạn đồng hành suốt đời.",
    ];

    final todayQuote = quotes[_selectedDate.day % quotes.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: AppTheme.primaryLight,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Câu nói hôm nay',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todayQuote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReadings() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomShimmer(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      );
    }

    if (_dailyReadings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'Không có bài đọc cho ngày này',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy chọn ngày khác hoặc kiểm tra lại sau',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedListView(
        children: _dailyReadings.map((reading) {
          return ReadingCard(
            reading: reading,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadingScreen(reading: reading),
                ),
              );
            },
            onBookmark: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      reading.isBookmarked ? 'Đã bỏ lưu' : 'Đã lưu bài đọc'),
                  backgroundColor: AppTheme.primaryLight,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      await _loadDailyReadings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Đọc theo ngày',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _isLoading = true;
              });
              _loadDailyReadings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildDailyQuote(),
          const SizedBox(height: 16),
          Expanded(child: _buildDailyReadings()),
        ],
      ),
    );
  }
}
