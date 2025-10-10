import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> gradientColors;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradientColors = AppTheme.primaryGradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(
          color: Colors.white,
        ),
        textAlign: textAlign,
      ),
    );
  }
}
