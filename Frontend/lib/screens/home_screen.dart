import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/json_liturgical_service.dart';
import '../models/daily_reading.dart';
import '../utils/app_theme.dart';
import 'daily_reading_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DailyReading? todayReading;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'vi_VN';
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _loadReading();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadReading() async {
    setState(() => isLoading = true);
    _fadeController.forward();

    final reading = await JsonLiturgicalService.getReadingForDate(selectedDate);

    setState(() {
      todayReading = reading;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryLight,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Bài Đọc Hàng Ngày',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppTheme.primaryGradient,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FavoritesScreen()),
                    );
                  },
                  tooltip: 'Yêu thích',
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  tooltip: 'Tìm kiếm',
                ),
                IconButton(
                  icon: const Icon(Icons.today, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selectedDate = DateTime.now();
                      focusedDate = DateTime.now();
                    });
                    _loadReading();
                  },
                  tooltip: 'Về hôm nay',
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            _buildModernCalendar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : todayReading == null
                      ? _buildNoReadingView()
                      : _buildReadingView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCalendar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2025, 1, 1),
            lastDay: DateTime(2025, 12, 31),
            focusedDay: focusedDate,
            calendarFormat: calendarFormat,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              HapticFeedback.lightImpact();
              setState(() {
                selectedDate = selectedDay;
                this.focusedDate = focusedDay;
              });
              _loadReading();
            },
            onPageChanged: (focusedDay) {
              focusedDate = focusedDay;
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Tháng',
              CalendarFormat.week: 'Tuần',
            },
            locale: 'vi_VN',
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              formatButtonPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppTheme.primaryLight,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppTheme.primaryLight,
              ),
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.secondaryGradient,
                ),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                ),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
              weekendTextStyle: TextStyle(
                color: AppTheme.primaryLight,
              ),
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(6),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              weekdayStyle: TextStyle(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onFormatChanged: (format) {
              setState(() => calendarFormat = format);
            },
          ),
          // Expand/Collapse button
          InkWell(
            onTap: () {
              setState(() {
                calendarFormat = calendarFormat == CalendarFormat.week
                    ? CalendarFormat.month
                    : CalendarFormat.week;
              });
            },
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    calendarFormat == CalendarFormat.week
                        ? Icons.expand_more
                        : Icons.expand_less,
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    calendarFormat == CalendarFormat.week
                        ? 'Xem tháng đầy đủ'
                        : 'Thu gọn',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReadingView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: 60,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Không có bài đọc cho ngày này',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _getDateString(),
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadReading();
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Thử lại',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadReading,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Modern Header Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppTheme.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryLight.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      todayReading!.saintName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDateString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 Bài Đọc Trong Thánh Lễ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reading Cards
                    ...todayReading!.readings.asMap().entries.map((entry) {
                      return _buildNewReadingCard(entry.value, entry.key);
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewReadingCard(ReadingReference reading, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    List<Color> gradientColors;
    String displayType = reading.type;

    if (reading.type.contains('Tin Mừng')) {
      icon = Icons.auto_stories_rounded;
      gradientColors = AppTheme.warmGradient;
    } else if (reading.type.contains('Bài Đọc 1') ||
        reading.type.contains('Bài 1')) {
      icon = Icons.book_rounded;
      gradientColors = AppTheme.coolGradient;
      displayType = 'Bài Đọc 1';
    } else if (reading.type.contains('Bài Đọc 2') ||
        reading.type.contains('Bài 2')) {
      icon = Icons.book_rounded;
      gradientColors = [AppTheme.primaryLight, AppTheme.secondaryLight];
      displayType = 'Bài Đọc 2';
    } else {
      icon = Icons.menu_book_rounded;
      gradientColors = [AppTheme.accentLight, AppTheme.primaryLight];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _openReading(reading);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gradientColors[0].withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Icon với gradient background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayType.toUpperCase(),
                        style: TextStyle(
                          color: gradientColors[0],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reading.fullReference,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: gradientColors[0],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDateString() {
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
    final weekday = weekDays[selectedDate.weekday];

    return '$weekday, ngày ${selectedDate.day} tháng ${selectedDate.month} năm ${selectedDate.year}';
  }

  void _openReading(ReadingReference reading) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReadingScreen(
          date: DateFormat('yyyy-MM-dd').format(selectedDate),
        ),
      ),
    );
  }
}
