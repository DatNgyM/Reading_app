import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/reading_card.dart';
import '../widgets/animated_widgets.dart';
import '../data/sample_data.dart';
import '../models/reading_item.dart';
import '../utils/app_theme.dart';
import 'reading_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  List<ReadingItem> _allReadings = [];
  List<ReadingItem> _bookmarkedReadings = [];
  List<ReadingItem> _completedReadings = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _allReadings = SampleData.getAllReadings();
      _bookmarkedReadings =
          _allReadings.where((reading) => reading.isBookmarked).toList();
      _completedReadings =
          _allReadings.where((reading) => reading.isCompleted).toList();
      _isLoading = false;
    });
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Đã lưu'),
          Tab(text: 'Hoàn thành'),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tổng bài đọc',
              '${_allReadings.length}',
              Icons.library_books_rounded,
              AppTheme.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Đã lưu',
              '${_bookmarkedReadings.length}',
              Icons.bookmark_rounded,
              AppTheme.secondaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Hoàn thành',
              '${_completedReadings.length}',
              Icons.check_circle_rounded,
              AppTheme.accentLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReadingList(List<ReadingItem> readings) {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomShimmer(
              width: double.infinity,
              height: 100,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      );
    }

    if (readings.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedListView(
      children: readings.map((reading) {
        return ReadingCard(
          reading: reading,
          isCompact: true,
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
                content:
                    Text(reading.isBookmarked ? 'Đã bỏ lưu' : 'Đã lưu bài đọc'),
                backgroundColor: AppTheme.primaryLight,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedTab) {
      case 0:
        title = 'Chưa có bài đọc nào';
        subtitle = 'Hãy khám phá các bài đọc mới trong ứng dụng';
        icon = Icons.library_books_outlined;
        break;
      case 1:
        title = 'Chưa có bài đọc nào được lưu';
        subtitle = 'Lưu các bài đọc yêu thích để đọc sau';
        icon = Icons.bookmark_outline;
        break;
      case 2:
        title = 'Chưa hoàn thành bài đọc nào';
        subtitle = 'Bắt đầu đọc và hoàn thành bài đọc đầu tiên';
        icon = Icons.check_circle_outline;
        break;
      default:
        title = 'Không có dữ liệu';
        subtitle = '';
        icon = Icons.info_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to search or home
                Navigator.pop(context);
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Khám phá bài đọc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildReadingList(_allReadings);
      case 1:
        return _buildReadingList(_bookmarkedReadings);
      case 2:
        return _buildReadingList(_completedReadings);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thư viện',
        showBackButton: false,
      ),
      body: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }
}
