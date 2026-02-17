import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class AgeSetupScreen extends StatefulWidget {
  const AgeSetupScreen({super.key});

  @override
  State<AgeSetupScreen> createState() => _AgeSetupScreenState();
}

class _AgeSetupScreenState extends State<AgeSetupScreen> {
  String? _selectedAge;

  final List<Map<String, dynamic>> _ageGroups = [
    {'label': 'setup.age.age_3_5', 'icon': Icons.child_care},
    {'label': 'setup.age.age_6_8', 'icon': Icons.face},
    {'label': 'setup.age.age_9_12', 'icon': Icons.boy},
    {'label': 'setup.age.age_13_plus', 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canProceed = _selectedAge != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  _buildBackButton(colorScheme),
                  const Spacer(),
                  _buildStepIndicator(4, 7),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.age.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.age.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Age options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _ageGroups.length,
                        itemBuilder: (context, index) {
                          final age = _ageGroups[index];
                          final isSelected = _selectedAge == age['label'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAge = age['label'] as String;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.colors.primary
                                          .withValues(alpha: 0.08)
                                      : colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.3),
                                  borderRadius: context.radius.panel,
                                  border: Border.all(
                                    color: isSelected
                                        ? context.colors.primary
                                        : colorScheme.outline,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? context.colors.primary
                                                .withValues(alpha: 0.15)
                                            : colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: context.radius.panel,
                                      ),
                                      child: Icon(
                                        age['icon'] as IconData,
                                        size: 24,
                                        color: isSelected
                                            ? context.colors.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        (age['label'] as String).tr(),
                                        style:
                                            theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? context.colors.primary
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: context.colors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: context.colors.textOnFilled,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Primary button
                    _buildPrimaryButton(
                      text: 'common.next'.tr(),
                      isEnabled: canProceed,
                      onPressed: () =>
                          context.go(AppRoutes.personalitySetup.path),
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    GestureDetector(
                      onTap: () => context.go(AppRoutes.home.path),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'setup.connection.skip_setup'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.panelPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(ColorScheme colorScheme) => GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: context.radius.tile,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );

  Widget _buildStepIndicator(int current, int total) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (index) {
          final isActive = index < current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? context.colors.primary
                  : context.colors.primary.withValues(alpha: 0.2),
              borderRadius: context.radius.checkbox,
            ),
          );
        }),
      );

  Widget _buildPrimaryButton({
    required String text,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) =>
      GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [
                      context.colors.primary100,
                      context.colors.primary,
                    ],
                  )
                : null,
            color: isEnabled
                ? null
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
            borderRadius: context.radius.panel,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isEnabled
                        ? context.colors.textOnFilled
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      );
}
