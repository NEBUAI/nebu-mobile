import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _profileVisible = true;
  bool _shareActivityData = false;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('privacy.title'.tr()),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Visibility Section
          _buildSectionHeader('privacy.profile_visibility'.tr(), theme),
          _buildCard(
            theme,
            children: [
              SwitchListTile(
                title: Text('privacy.public_profile'.tr()),
                subtitle: Text('privacy.public_profile_desc'.tr()),
                value: _profileVisible,
                onChanged: (value) {
                  setState(() => _profileVisible = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data Sharing Section
          _buildSectionHeader('privacy.data_sharing'.tr(), theme),
          _buildCard(
            theme,
            children: [
              SwitchListTile(
                title: Text('privacy.share_activity'.tr()),
                subtitle: Text('privacy.share_activity_desc'.tr()),
                value: _shareActivityData,
                onChanged: (value) {
                  setState(() => _shareActivityData = value);
                },
              ),
              const Divider(),
              SwitchListTile(
                title: Text('privacy.analytics'.tr()),
                subtitle: Text('privacy.analytics_desc'.tr()),
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() => _analyticsEnabled = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // App Permissions Section
          _buildSectionHeader('privacy.permissions'.tr(), theme),
          _buildCard(
            theme,
            children: [
              _buildPermissionTile(
                theme,
                Icons.bluetooth,
                'privacy.bluetooth'.tr(),
                'privacy.bluetooth_desc'.tr(),
                true,
              ),
              const Divider(),
              _buildPermissionTile(
                theme,
                Icons.camera_alt,
                'privacy.camera'.tr(),
                'privacy.camera_desc'.tr(),
                true,
              ),
              const Divider(),
              _buildPermissionTile(
                theme,
                Icons.location_on,
                'privacy.location'.tr(),
                'privacy.location_desc'.tr(),
                false,
              ),
              const Divider(),
              _buildPermissionTile(
                theme,
                Icons.mic,
                'privacy.microphone'.tr(),
                'privacy.microphone_desc'.tr(),
                true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Data Section
          _buildSectionHeader('privacy.account_data'.tr(), theme),
          _buildCard(
            theme,
            children: [
              ListTile(
                leading: Icon(Icons.download, color: theme.colorScheme.primary),
                title: Text('privacy.download_data'.tr()),
                subtitle: Text('privacy.download_data_desc'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDownloadDataDialog(),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.history, color: theme.colorScheme.primary),
                title: Text('privacy.login_history'.tr()),
                subtitle: Text('privacy.login_history_desc'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLoginHistoryDialog(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Legal Section
          _buildSectionHeader('privacy.legal'.tr(), theme),
          _buildCard(
            theme,
            children: [
              ListTile(
                leading: Icon(Icons.description, color: theme.colorScheme.primary),
                title: Text('privacy.privacy_policy'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.privacyPolicy.path);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.gavel, color: theme.colorScheme.primary),
                title: Text('privacy.terms_of_service'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.termsOfService.path);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('privacy.danger_zone'.tr(), theme),
          _buildCard(
            theme,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  'privacy.delete_account'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text('privacy.delete_account_desc'.tr()),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPermissionTile(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    bool granted,
  ) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Chip(
        label: Text(
          granted ? 'privacy.granted'.tr() : 'privacy.denied'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: granted ? Colors.green : Colors.orange,
          ),
        ),
        backgroundColor: granted
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('privacy.manage_in_settings'.tr()),
            action: SnackBarAction(
              label: 'privacy.open_settings'.tr(),
              onPressed: () {
                // TODO: Open app settings
              },
            ),
          ),
        );
      },
    );
  }

  void _showDownloadDataDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy.download_data'.tr()),
        content: Text('privacy.download_data_info'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('privacy.download_started'.tr()),
                ),
              );
            },
            child: Text('privacy.download'.tr()),
          ),
        ],
      ),
    );
  }

  void _showLoginHistoryDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy.login_history'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoginHistoryItem(
                'Android Device',
                'Lima, Peru',
                'Just now',
                true,
              ),
              const Divider(),
              _buildLoginHistoryItem(
                'Web Browser',
                'Lima, Peru',
                '2 days ago',
                false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('privacy.close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHistoryItem(
    String device,
    String location,
    String time,
    bool current,
  ) {
    return ListTile(
      leading: Icon(
        Icons.phone_android,
        color: current ? Colors.green : Colors.grey,
      ),
      title: Text(device),
      subtitle: Text('$location • $time'),
      trailing: current
          ? Chip(
              label: Text(
                'privacy.current'.tr(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
            )
          : null,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'privacy.delete_account'.tr(),
          style: const TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('privacy.delete_account_warning'.tr()),
            const SizedBox(height: 16),
            Text(
              'privacy.delete_account_consequences'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• ${('privacy.consequence_1'.tr())}'),
            Text('• ${('privacy.consequence_2'.tr())}'),
            Text('• ${('privacy.consequence_3'.tr())}'),
            Text('• ${('privacy.consequence_4'.tr())}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDeleteAccount();
              if (confirmed == true && mounted) {
                // TODO: Implement account deletion
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  context.go(AppRoutes.welcome.path);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('privacy.delete_permanently'.tr()),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDeleteAccount() {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy.confirm_deletion'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('privacy.type_delete_to_confirm'.tr()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'DELETE',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.toUpperCase() == 'DELETE') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('privacy.incorrect_confirmation'.tr()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}
