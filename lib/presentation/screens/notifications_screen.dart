import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data - Replace with actual notifications from provider
    final allNotifications = _getMockNotifications();
    final filteredNotifications = _filter == 'all'
        ? allNotifications
        : allNotifications.where((n) => n.type == _filter).toList();

    final unreadCount =
        allNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'notifications.mark_all_read'.tr(),
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('all', 'notifications.all'.tr(), theme),
                const SizedBox(width: 8),
                _buildFilterChip('toys', 'notifications.toys'.tr(), theme),
                const SizedBox(width: 8),
                _buildFilterChip('orders', 'notifications.orders'.tr(), theme),
                const SizedBox(width: 8),
                _buildFilterChip('system', 'notifications.system'.tr(), theme),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () => _dismissNotification(notification),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ThemeData theme) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'notifications.no_notifications'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'notifications.no_notifications_desc'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  void _markAllAsRead() {
    setState(() {
      // TODO(dev): Implement mark all as read
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('notifications.marked_all_read'.tr())),
    );
  }

  void _handleNotificationTap(_Notification notification) {
    setState(() {
      notification.isRead = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(notification.title)),
    );
  }

  void _dismissNotification(_Notification notification) {
    setState(() {
      _getMockNotifications().remove(notification);
    });
  }

  List<_Notification> _getMockNotifications() {
    // TODO(dev): Replace with actual API call
    return [
      _Notification(
        id: '1',
        title: 'Nebu Robot Connected',
        message: 'Your Nebu Robot "Buddy" is now connected',
        type: 'toys',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      _Notification(
        id: '2',
        title: 'Order Shipped',
        message: 'Your order #ORD-002 has been shipped',
        type: 'orders',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      _Notification(
        id: '3',
        title: 'New Feature Available',
        message: 'Check out the new voice commands feature!',
        type: 'system',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      _Notification(
        id: '4',
        title: 'Battery Low',
        message: 'Your Nebu Robot battery is at 15%',
        type: 'toys',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      _Notification(
        id: '5',
        title: 'Order Delivered',
        message: 'Your order #ORD-001 has been delivered',
        type: 'orders',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final _Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead
                ? Colors.transparent
                : theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type, theme)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type, theme),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'toys':
        return Icons.smart_toy;
      case 'orders':
        return Icons.shopping_bag;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type, ThemeData theme) {
    switch (type) {
      case 'toys':
        return Colors.blue;
      case 'orders':
        return Colors.green;
      case 'system':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'notifications.just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return 'notifications.minutes_ago'
          .tr(args: [difference.inMinutes.toString()]);
    } else if (difference.inHours < 24) {
      return 'notifications.hours_ago'
          .tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays < 7) {
      return 'notifications.days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}

// Mock model
class _Notification {

  _Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  bool isRead;
}
