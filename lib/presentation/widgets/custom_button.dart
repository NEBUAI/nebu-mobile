import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline }

class CustomButton extends StatelessWidget {

  const CustomButton({
    required this.text, super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
  });
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ],
    );

    final buttonWidth = width ?? (isFullWidth ? double.infinity : null);
    final buttonHeight = height ?? 56.0;

    switch (variant) {
      case ButtonVariant.primary:
        return Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppTheme.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: onPressed != null && !isLoading
                ? [
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              foregroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.outline:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              side: BorderSide(
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}
