import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/services/local_child_data_service.dart';
import '../providers/api_provider.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localChildDataService = ref.watch(localChildDataServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('child_profile.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: localChildDataService.when(
        data: (service) {
          if (!service.hasChildData()) {
            return _buildNoChildDataState(context, service, colorScheme);
          }
          return _buildChildProfileState(context, service, colorScheme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text('child_profile.error_generic'.tr())),
      ),
    );
  }

  Widget _buildNoChildDataState(
    BuildContext context,
    LocalChildDataService service,
    ColorScheme colorScheme,
  ) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.child_care, size: 80, color: Colors.grey),
        const SizedBox(height: 20),
        Text(
          'child_profile.no_data_title'.tr(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'child_profile.no_data_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => context.push(AppRoutes.localChildSetup.path),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text('child_profile.setup_profile'.tr()),
        ),
      ],
    ),
  );

  Widget _buildChildProfileState(
    BuildContext context,
    LocalChildDataService service,
    ColorScheme colorScheme,
  ) {
    final childData = service.getChildData();
    final childName = childData['name'] ?? 'Child';
    final childAge = childData['age'];
    final childPersonality = childData['personality'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    childName[0].toUpperCase(),
                    style: TextStyle(fontSize: 40, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  childName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (childAge != null)
                  Text(
                    'child_profile.age'.tr(args: [childAge]),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          _buildSectionTitle('child_profile.personality'.tr()),
          Wrap(
            spacing: 8,
            children: [
              if (childPersonality != null)
                _buildInfoChip(childPersonality, Icons.psychology, colorScheme),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.localChildSetup.path),
                icon: const Icon(Icons.edit, color: Colors.grey),
                label: Text(
                  'profile.edit_profile'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, service, colorScheme),
                icon: Icon(Icons.delete, color: colorScheme.error),
                label: Text(
                  'child_profile.delete_profile'.tr(),
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildInfoChip(String label, IconData icon, ColorScheme colorScheme) =>
      Chip(
        avatar: Icon(icon, color: colorScheme.primary, size: 18),
        label: Text(label),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
        ),
      );

  void _confirmDelete(
    BuildContext context,
    LocalChildDataService service,
    ColorScheme colorScheme,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('child_profile.confirm_deletion_title'.tr()),
        content: Text(
          'child_profile.confirm_deletion_message'.tr(),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('common.cancel'.tr()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('common.delete'.tr(), style: TextStyle(color: colorScheme.error)),
            onPressed: () async {
              await service.clearChildData();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
