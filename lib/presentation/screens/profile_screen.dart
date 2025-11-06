import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final ThemeState themeState = ref.watch(themeProvider);
    final LanguageState languageState = ref.watch(languageProvider);
    final isDark = themeState.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'profile.title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header Card - Simplified and Clean
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.08,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: authState.user?.avatar != null
                          ? ClipOval(
                              child: Image.network(
                                authState.user!.avatar!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                (authState.user?.name ?? 'U')[0].toUpperCase(),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Name and View Profile
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user?.name ?? 'profile.user'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View Profile',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Settings Icon
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      onPressed: () {
                        context.push(AppConstants.routeEditProfile);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Access Items
              _SettingsCard(
                theme: theme,
                isDark: isDark,
                children: [
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.receipt_long_outlined,
                    title: 'Your orders',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orders feature coming soon'),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 56, color: theme.dividerColor),
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.notifications_outlined,
                    title: 'profile.notifications'.tr(),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications feature coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Settings Section Header
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Settings Card
              _SettingsCard(
                theme: theme,
                isDark: isDark,
                children: [
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.dark_mode_outlined,
                    title: 'profile.dark_mode'.tr(),
                    trailing: Switch(
                      value: themeState.isDarkMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleDarkMode();
                      },
                      activeTrackColor: AppTheme.primaryLight.withValues(
                        alpha: 0.5,
                      ),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.primaryLight;
                        }
                        return null;
                      }),
                    ),
                  ),
                  Divider(height: 1, indent: 56, color: theme.dividerColor),
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.language_outlined,
                    title: 'profile.language'.tr(),
                    trailing: DropdownButton<String>(
                      value: languageState.languageCode,
                      underline: const SizedBox(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      dropdownColor: theme.colorScheme.surface,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('profile.english'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'es',
                          child: Text('profile.spanish'.tr()),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(languageProvider.notifier)
                              .setLanguage(value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Account Section
              _SettingsCard(
                theme: theme,
                isDark: isDark,
                children: [
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.person_outline,
                    title: 'profile.edit_profile'.tr(),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      context.push(AppConstants.routeEditProfile);
                    },
                  ),
                  Divider(height: 1, indent: 56, color: theme.dividerColor),
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.privacy_tip_outlined,
                    title: 'profile.privacy'.tr(),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Help & About Section
              _SettingsCard(
                theme: theme,
                isDark: isDark,
                children: [
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.help_outline,
                    title: 'profile.help_support'.tr(),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                  Divider(height: 1, indent: 56, color: theme.dividerColor),
                  _SettingsTile(
                    theme: theme,
                    icon: Icons.info_outline,
                    title: 'profile.about'.tr(),
                    trailing: Text(
                      'v${AppConstants.appVersion}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Button
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: isDark ? 0.4 : 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      final shouldLogout = await _showLogoutDialog(context);
                      if (shouldLogout ?? false) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(AppConstants.routeWelcome);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'profile.logout'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('profile.logout'.tr()),
      content: Text('profile.logout_confirmation'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('profile.logout'.tr()),
        ),
      ],
    ),
  );
}

void _showHelpDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Help & Support'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Need help with your Nebu toys?'),
          const SizedBox(height: 16),
          _buildHelpOption(Icons.email, 'Email Support', 'support@nebu.ai'),
          const SizedBox(height: 8),
          _buildHelpOption(Icons.phone, 'Phone', '+1 (555) 123-4567'),
          const SizedBox(height: 8),
          _buildHelpOption(Icons.chat, 'Live Chat', 'Available 9AM-5PM EST'),
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

Widget _buildHelpOption(IconData icon, String title, String subtitle) => Row(
    children: [
      Icon(icon, size: 20),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ],
  );

void _showAboutDialog(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: AppConstants.appName,
    applicationVersion: AppConstants.appVersion,
    applicationIcon: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.smart_toy, color: Colors.white, size: 32),
    ),
    children: [
      const SizedBox(height: 16),
      const Text(
        'Nebu Mobile brings your interactive toys to life with AI-powered conversations and personalized experiences.',
      ),
      const SizedBox(height: 8),
      const Text('© 2025 Nebu AI. All rights reserved.'),
    ],
  );
}

// Settings Card Widget
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.children,
    required this.theme,
    required this.isDark,
  });

  final List<Widget> children;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.theme,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    leading: Icon(
      icon,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      size: 24,
    ),
    title: Text(
      title,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    ),
    trailing: trailing,
    onTap: onTap,
  );
}
