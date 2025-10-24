import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../models/user_settings.dart';
import '../utils/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  UserSettings _settings = UserSettings();
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
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _updateSettings(UserSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu cài đặt'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryLight,
            ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppTheme.primaryLight),
        activeColor: AppTheme.primaryLight,
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryLight),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: AppTheme.primaryLight,
            ),
            Text(
              '${value.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryLight),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
        onTap: () {
          _showDropdownDialog(title, value, items, onChanged);
        },
      ),
    );
  }

  Widget _buildActionSetting({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryLight),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showDropdownDialog(String title, String currentValue,
      List<String> items, ValueChanged<String> onChanged) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ...items.map((item) {
              return ListTile(
                title: Text(item),
                leading: Radio<String>(
                  value: item,
                  groupValue: currentValue,
                  onChanged: (value) {
                    if (value != null) {
                      onChanged(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  onChanged(item);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Reading App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.book_rounded, size: 48),
      children: [
        const Text('Ứng dụng hỗ trợ đọc sách theo ngày và đạo'),
        const SizedBox(height: 16),
        const Text('Phát triển bởi: Your Name'),
        const Text('Email: your.email@example.com'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Cài đặt', showBackButton: false),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryLight),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Cài đặt', showBackButton: false),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          children: [
            // Appearance Section
            _buildSectionHeader('Giao diện'),
            _buildToggleSetting(
              title: 'Chế độ tối',
              subtitle: 'Sử dụng giao diện tối',
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
              icon: Icons.dark_mode_rounded,
            ),
            _buildDropdownSetting(
              title: 'Ngôn ngữ',
              subtitle: 'Chọn ngôn ngữ hiển thị',
              value: _settings.language == 'vi' ? 'Tiếng Việt' : 'English',
              items: const ['Tiếng Việt', 'English'],
              onChanged: (value) {
                _updateSettings(_settings.copyWith(
                  language: value == 'Tiếng Việt' ? 'vi' : 'en',
                ));
              },
              icon: Icons.language_rounded,
            ),

            // Reading Preferences
            _buildSectionHeader('Tùy chọn đọc'),
            _buildSliderSetting(
              title: 'Mục tiêu đọc hàng ngày',
              subtitle: 'Thời gian đọc mục tiêu mỗi ngày',
              value: _settings.dailyReadingGoal.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              onChanged: (value) {
                _updateSettings(
                    _settings.copyWith(dailyReadingGoal: value.toInt()));
              },
              icon: Icons.timer_rounded,
            ),
            _buildDropdownSetting(
              title: 'Độ khó ưa thích',
              subtitle: 'Chọn độ khó phù hợp với bạn',
              value: _settings.preferredDifficulty,
              items: const ['Easy', 'Medium', 'Hard'],
              onChanged: (value) {
                _updateSettings(_settings.copyWith(preferredDifficulty: value));
              },
              icon: Icons.speed_rounded,
            ),
            _buildDropdownSetting(
              title: 'Chế độ đọc',
              subtitle: 'Cách hiển thị nội dung',
              value: _settings.readingMode == 'scroll' ? 'Cuộn' : 'Trang',
              items: const ['Cuộn', 'Trang'],
              onChanged: (value) {
                _updateSettings(_settings.copyWith(
                  readingMode: value == 'Cuộn' ? 'scroll' : 'page',
                ));
              },
              icon: Icons.chrome_reader_mode_rounded,
            ),

            // Notifications
            _buildSectionHeader('Thông báo'),
            _buildToggleSetting(
              title: 'Bật thông báo',
              subtitle: 'Nhận thông báo nhắc nhở đọc sách',
              value: _settings.notificationsEnabled,
              onChanged: (value) {
                _updateSettings(
                    _settings.copyWith(notificationsEnabled: value));
              },
              icon: Icons.notifications_rounded,
            ),

            // Features
            _buildSectionHeader('Tính năng'),
            _buildToggleSetting(
              title: 'Tự động phát audio',
              subtitle: 'Tự động phát audio khi có',
              value: _settings.autoPlayAudio,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(autoPlayAudio: value));
              },
              icon: Icons.volume_up_rounded,
            ),
            _buildToggleSetting(
              title: 'Phản hồi xúc giác',
              subtitle: 'Rung nhẹ khi tương tác',
              value: _settings.enableHapticFeedback,
              onChanged: (value) {
                _updateSettings(
                    _settings.copyWith(enableHapticFeedback: value));
              },
              icon: Icons.vibration_rounded,
            ),
            _buildToggleSetting(
              title: 'Bật bookmark',
              subtitle: 'Lưu bài đọc yêu thích',
              value: _settings.enableBookmarks,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(enableBookmarks: value));
              },
              icon: Icons.bookmark_rounded,
            ),
            _buildToggleSetting(
              title: 'Bật ghi chú',
              subtitle: 'Thêm ghi chú vào bài đọc',
              value: _settings.enableNotes,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(enableNotes: value));
              },
              icon: Icons.note_add_rounded,
            ),
            _buildToggleSetting(
              title: 'Bật highlight',
              subtitle: 'Tô sáng đoạn văn quan trọng',
              value: _settings.enableHighlights,
              onChanged: (value) {
                _updateSettings(_settings.copyWith(enableHighlights: value));
              },
              icon: Icons.highlight_rounded,
            ),

            // About
            _buildSectionHeader('Thông tin'),
            _buildActionSetting(
              title: 'Phiên bản',
              subtitle: '1.0.0',
              onTap: _showAboutDialog,
              icon: Icons.info_rounded,
            ),
            _buildActionSetting(
              title: 'Đánh giá ứng dụng',
              subtitle: 'Đánh giá trên cửa hàng',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
                );
              },
              icon: Icons.star_rounded,
              iconColor: Colors.orange,
            ),
            _buildActionSetting(
              title: 'Chia sẻ ứng dụng',
              subtitle: 'Giới thiệu với bạn bè',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã chia sẻ ứng dụng')),
                );
              },
              icon: Icons.share_rounded,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
