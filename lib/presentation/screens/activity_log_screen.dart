import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('activity_log.title'.tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppTheme.primaryGradient,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(
                Icons.history,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'activity_log.view_history'.tr(),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'activity_log.coming_soon'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
