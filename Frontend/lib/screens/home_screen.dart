import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/json_liturgical_service.dart';
import '../models/daily_reading.dart';
import 'daily_reading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyReading? todayReading;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;
  bool showFullCalendar = false;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'vi_VN';
    _loadReading();
  }

  Future<void> _loadReading() async {
    setState(() => isLoading = true);

    // Load reading cho ngày đã chọn
    final reading = await JsonLiturgicalService.getReadingForDate(selectedDate);

    setState(() {
      todayReading = reading;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài Đọc Hàng Ngày'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
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
      body: Column(
        children: [
          // Compact Calendar - always visible
          _buildCompactCalendar(),

          // Reading content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : todayReading == null
                    ? _buildNoReadingView()
                    : _buildReadingView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
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
              CalendarFormat.twoWeeks: '2 Tuần',
              CalendarFormat.week: 'Tuần',
            },
            locale: 'vi_VN',
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Colors.red[700]!),
                borderRadius: BorderRadius.circular(8),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
              formatButtonPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Colors.red[700],
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Colors.red[700],
              ),
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.red[300],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.red[700],
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(
                color: Colors.red,
              ),
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(4),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              weekdayStyle: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onFormatChanged: (format) {
              setState(() {
                calendarFormat = format;
              });
            },
          ),
          // Expand/Collapse button
          InkWell(
            onTap: () {
              setState(() {
                if (calendarFormat == CalendarFormat.week) {
                  calendarFormat = CalendarFormat.month;
                } else {
                  calendarFormat = CalendarFormat.week;
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    calendarFormat == CalendarFormat.week
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    calendarFormat == CalendarFormat.week
                        ? 'Xem thêm'
                        : 'Thu gọn',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có bài đọc cho ngày này',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _getDateString(),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadReading,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingView() {
    return RefreshIndicator(
      onRefresh: _loadReading,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header với thánh và ngày đã chọn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[700]!, Colors.red[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _getDateString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    todayReading!.saintName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${todayReading!.readings.length} Bài Đọc',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách bài đọc dạng nút bấm
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bài đọc trong Thánh lễ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...todayReading!.readings.asMap().entries.map((entry) {
                    return _buildReadingButton(entry.value, entry.key);
                  }).toList(),
                ],
              ),
            ),
          ],
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

  Widget _buildReadingButton(ReadingReference reading, int index) {
    IconData icon;
    Color color;
    String displayType = reading.type;

    if (reading.type.contains('Tin Mừng')) {
      icon = Icons.auto_stories;
      color = Colors.amber[700]!;
    } else if (reading.type.contains('Bài Đọc 1') ||
        reading.type.contains('Bài 1')) {
      icon = Icons.book;
      color = Colors.blue;
      displayType = 'Bài Đọc 1';
    } else if (reading.type.contains('Bài Đọc 2') ||
        reading.type.contains('Bài 2')) {
      icon = Icons.book;
      color = Colors.green;
      displayType = 'Bài Đọc 2';
    } else {
      icon = Icons.menu_book;
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openReading(reading),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayType,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reading.fullReference,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
