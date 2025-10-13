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

    return Scaffold(
      appBar: AppBar(
        title: Text('profile.title'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: authState.user?.avatar != null
                          ? ClipOval(
                              child: Image.network(
                                authState.user!.avatar!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryLight,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.user?.name ?? 'profile.user'.tr(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: Text('profile.dark_mode'.tr()),
                      trailing: Switch(
                        value: themeState.isDarkMode,
                        onChanged: (value) {
                          ref.read(themeProvider.notifier).toggleDarkMode();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text('profile.language'.tr()),
                      trailing: DropdownButton<String>(
                        value: languageState.languageCode,
                        underline: const SizedBox(),
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
                            ref.read(languageProvider.notifier).setLanguage(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('profile.edit_profile'.tr()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO(dev): Navigate to edit profile
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text('profile.notifications'.tr()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO(dev): Navigate to notifications settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: Text('profile.privacy'.tr()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO(dev): Navigate to privacy settings
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // About Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: Text('profile.help_support'.tr()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO(duvet05): Navigate to help
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text('profile.about'.tr()),
                      trailing: const Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        // TODO(duvet05): Show about dialog
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
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
                  ),
                  child: Text('profile.logout'.tr()),
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
            child: Text('profile.logout'.tr()),
          ),
        ],
      ),
    );
}
