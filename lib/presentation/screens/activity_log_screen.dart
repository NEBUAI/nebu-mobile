import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../core/theme/app_theme.dart';

class ActivityLogController extends GetxController {
  final activities = <ActivityLog>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  void loadActivities() {
    isLoading.value = true;

    // TODO: Implement API call to fetch activities
    // For now, show empty state or cached data
    Future.delayed(const Duration(seconds: 1), () {
      activities.value = [];
      isLoading.value = false;
    });
  }

  void filterActivities(String filter) {
    selectedFilter.value = filter;
    loadActivities();
  }

  void refreshActivities() {
    loadActivities();
  }
}

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.toyName,
    required this.action,
    required this.timestamp,
    required this.icon,
    this.details,
  });
  final String id;
  final String toyName;
  final String action;
  final DateTime timestamp;
  final IconData icon;
  final String? details;
}

class ActivityLogScreen extends StatelessWidget {
  ActivityLogScreen({super.key});

  final ActivityLogController controller = Get.put(ActivityLogController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('activity_log.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activities.isEmpty) {
          return _buildEmptyState(theme);
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshActivities();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activities.length,
            itemBuilder: (context, index) {
              final activity = controller.activities[index];
              return _buildActivityCard(activity, theme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppTheme.primaryGradient),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Icon(Icons.history, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text('No Activity Yet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your toy interactions and activities will appear here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildActivityCard(ActivityLog activity, ThemeData theme) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
          child: Icon(activity.icon, color: AppTheme.primaryLight),
        ),
        title: Text(
          activity.action,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(activity.toyName),
            if (activity.details != null) ...[
              const SizedBox(height: 2),
              Text(
                activity.details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          _formatTimestamp(activity.timestamp),
          style: theme.textTheme.bodySmall,
        ),
      ),
    );

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Activities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All Activities', 'all'),
            _buildFilterOption('Connections', 'connection'),
            _buildFilterOption('Play Sessions', 'play'),
            _buildFilterOption('Updates', 'update'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) => Obx(
      () => RadioListTile<String>(
        title: Text(label),
        value: value,
        groupValue: controller.selectedFilter.value,
        onChanged: (val) {
          if (val != null) {
            controller.filterActivities(val);
          }
        },
      ),
    );
}
