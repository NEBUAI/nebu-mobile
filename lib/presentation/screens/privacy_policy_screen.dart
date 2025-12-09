import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSpanish = context.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text('privacy_policy.title'.tr()),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'privacy_policy.header'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'privacy_policy.last_updated'.tr(args: ['December 9, 2025']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              theme,
              'privacy_policy.introduction_title'.tr(),
              'privacy_policy.introduction_content'.tr(args: [AppConfig.appName]),
            ),

            // Information We Collect
            _buildSection(
              theme,
              'privacy_policy.collect_title'.tr(),
              'privacy_policy.collect_content'.tr(),
            ),
            _buildBulletPoint(theme, 'privacy_policy.collect_1'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.collect_2'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.collect_3'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.collect_4'.tr()),
            const SizedBox(height: 16),

            // How We Use Your Information
            _buildSection(
              theme,
              'privacy_policy.use_title'.tr(),
              'privacy_policy.use_content'.tr(),
            ),
            _buildBulletPoint(theme, 'privacy_policy.use_1'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.use_2'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.use_3'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.use_4'.tr()),
            const SizedBox(height: 16),

            // Data Sharing
            _buildSection(
              theme,
              'privacy_policy.sharing_title'.tr(),
              'privacy_policy.sharing_content'.tr(),
            ),

            // Children's Privacy
            _buildSection(
              theme,
              'privacy_policy.children_title'.tr(),
              'privacy_policy.children_content'.tr(),
            ),

            // Your Rights
            _buildSection(
              theme,
              'privacy_policy.rights_title'.tr(),
              'privacy_policy.rights_content'.tr(),
            ),
            _buildBulletPoint(theme, 'privacy_policy.rights_1'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.rights_2'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.rights_3'.tr()),
            _buildBulletPoint(theme, 'privacy_policy.rights_4'.tr()),
            const SizedBox(height: 16),

            // Data Security
            _buildSection(
              theme,
              'privacy_policy.security_title'.tr(),
              'privacy_policy.security_content'.tr(),
            ),

            // Changes to Policy
            _buildSection(
              theme,
              'privacy_policy.changes_title'.tr(),
              'privacy_policy.changes_content'.tr(),
            ),

            // Contact
            _buildSection(
              theme,
              'privacy_policy.contact_title'.tr(),
              'privacy_policy.contact_content'.tr(),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'privacy_policy.email_label'.tr(),
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'privacy@nebu.ai',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
