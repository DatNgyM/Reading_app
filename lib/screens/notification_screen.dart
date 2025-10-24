import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/animated_widgets.dart';
import '../data/sample_data.dart';
import '../models/notification_item.dart';
import '../utils/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _notifications = SampleData.getNotifications();
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    });

    HapticFeedback.lightImpact();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả là đã đọc'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications
          .removeWhere((notification) => notification.id == notificationId);
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa thông báo'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reading_reminder':
        return Icons.book_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'update':
        return Icons.update_rounded;
      case 'new_content':
        return Icons.new_releases_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reading_reminder':
        return AppTheme.primaryLight;
      case 'achievement':
        return Colors.orange;
      case 'update':
        return AppTheme.secondaryLight;
      case 'new_content':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                : color.withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: notification.isRead
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            notification.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(notification.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                  const Spacer(),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ],
          ),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có thông báo nào',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chúng tôi sẽ thông báo cho bạn khi có nội dung mới',
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

  Widget _buildLoadingState() {
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

  Widget _buildNotificationList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedListView(
      children: _notifications.map((notification) {
        return _buildNotificationCard(notification);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thông báo',
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: Column(
        children: [
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.all(16),
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
                    Icons.info_rounded,
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn có $unreadCount thông báo chưa đọc',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text('Đánh dấu tất cả'),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildNotificationList()),
        ],
      ),
    );
  }
}
