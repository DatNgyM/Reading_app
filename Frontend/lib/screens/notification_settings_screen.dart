import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _isEnabled = false;
  int _selectedHour = 7;
  int _selectedMinute = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final settings = await _notificationService.loadNotificationSettings();

    setState(() {
      _isEnabled = settings['enabled'] ?? false;
      _selectedHour = settings['hour'] ?? 7;
      _selectedMinute = settings['minute'] ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      try {
        // Request all permissions first
        final hasPermission = await _notificationService.requestPermissions();

        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng cấp quyền thông báo trong Cài đặt'),
                action: SnackBarAction(
                  label: 'Mở Cài đặt',
                  onPressed: openAppSettings,
                ),
              ),
            );
          }
          return;
        }
        // Schedule notification
        await _notificationService.scheduleDailyNotification(
          hour: _selectedHour,
          minute: _selectedMinute,
          title: 'Bài đọc hàng ngày',
          body:
              'Đã đến giờ đọc Kinh Thánh! Hãy mở ứng dụng để xem bài đọc hôm nay.',
        );

        setState(() => _isEnabled = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã bật thông báo lúc ${_formatTime(_selectedHour, _selectedMinute)}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error scheduling notification: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Cài đặt',
                textColor: Colors.white,
                onPressed: () async {
                  await openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } else {
      await _notificationService.cancelAllNotifications();
      setState(() => _isEnabled = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tắt thông báo')),
        );
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryLight,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });

      // If notifications are enabled, reschedule with new time
      if (_isEnabled) {
        await _notificationService.scheduleDailyNotification(
          hour: _selectedHour,
          minute: _selectedMinute,
          title: 'Bài đọc hàng ngày',
          body:
              'Đã đến giờ đọc Kinh Thánh! Hãy mở ứng dụng để xem bài đọc hôm nay.',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã cập nhật thời gian thông báo: ${_formatTime(_selectedHour, _selectedMinute)}',
              ),
            ),
          );
        }
      }
    }
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppTheme.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 64,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nhắc nhở đọc Kinh Thánh',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhận thông báo hàng ngày để đọc Lời Chúa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Enable/Disable Switch
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Bật thông báo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _isEnabled ? 'Đang bật' : 'Đang tắt',
                      style: TextStyle(
                        color: _isEnabled ? Colors.green : Colors.grey,
                      ),
                    ),
                    value: _isEnabled,
                    activeColor: AppTheme.primaryLight,
                    onChanged: _toggleNotifications,
                  ),
                ),

                const SizedBox(height: 16),

                // Time Picker
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: AppTheme.primaryLight,
                    ),
                    title: const Text(
                      'Thời gian nhắc nhở',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _formatTime(_selectedHour, _selectedMinute),
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectTime,
                  ),
                ),

                const SizedBox(height: 24),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryLight.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryLight,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bạn sẽ nhận thông báo vào thời gian đã chọn mỗi ngày',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
