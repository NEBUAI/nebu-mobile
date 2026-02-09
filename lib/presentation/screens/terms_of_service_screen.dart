import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/config.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('terms.title'.tr()), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'terms.header'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'terms.last_updated'.tr(args: ['December 9, 2025']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              theme,
              'terms.introduction_title'.tr(),
              'terms.introduction_content'.tr(args: [Config.appName]),
            ),

            // Acceptance
            _buildSection(
              theme,
              'terms.acceptance_title'.tr(),
              'terms.acceptance_content'.tr(),
            ),

            // Use of Service
            _buildSection(
              theme,
              'terms.use_title'.tr(),
              'terms.use_content'.tr(),
            ),
            _buildBulletPoint(theme, 'terms.use_1'.tr()),
            _buildBulletPoint(theme, 'terms.use_2'.tr()),
            _buildBulletPoint(theme, 'terms.use_3'.tr()),
            _buildBulletPoint(theme, 'terms.use_4'.tr()),
            const SizedBox(height: 16),

            // Account Responsibilities
            _buildSection(
              theme,
              'terms.account_title'.tr(),
              'terms.account_content'.tr(),
            ),

            // Prohibited Activities
            _buildSection(
              theme,
              'terms.prohibited_title'.tr(),
              'terms.prohibited_content'.tr(),
            ),
            _buildBulletPoint(theme, 'terms.prohibited_1'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_2'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_3'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_4'.tr()),
            _buildBulletPoint(theme, 'terms.prohibited_5'.tr()),
            const SizedBox(height: 16),

            // Intellectual Property
            _buildSection(
              theme,
              'terms.ip_title'.tr(),
              'terms.ip_content'.tr(),
            ),

            // User Content
            _buildSection(
              theme,
              'terms.user_content_title'.tr(),
              'terms.user_content_content'.tr(),
            ),

            // Termination
            _buildSection(
              theme,
              'terms.termination_title'.tr(),
              'terms.termination_content'.tr(),
            ),

            // Disclaimers
            _buildSection(
              theme,
              'terms.disclaimers_title'.tr(),
              'terms.disclaimers_content'.tr(),
            ),

            // Limitation of Liability
            _buildSection(
              theme,
              'terms.liability_title'.tr(),
              'terms.liability_content'.tr(),
            ),

            // Changes to Terms
            _buildSection(
              theme,
              'terms.changes_title'.tr(),
              'terms.changes_content'.tr(),
            ),

            // Governing Law
            _buildSection(
              theme,
              'terms.law_title'.tr(),
              'terms.law_content'.tr(),
            ),

            // Contact
            _buildSection(
              theme,
              'terms.contact_title'.tr(),
              'terms.contact_content'.tr(),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'terms.contact_info'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContactRow(theme, Icons.email, 'legal@nebu.ai'),
                  const SizedBox(height: 8),
                  _buildContactRow(theme, Icons.language, 'www.nebu.ai'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) =>
      Padding(
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
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      );

  Widget _buildBulletPoint(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: theme.textTheme.bodyMedium),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    ),
  );

  Widget _buildContactRow(ThemeData theme, IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      Text(text, style: theme.textTheme.bodyMedium),
    ],
  );
}
