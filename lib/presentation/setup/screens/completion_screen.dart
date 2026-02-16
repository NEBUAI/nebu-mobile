import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _checkAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startAnimations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _animationController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _checkAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final SetupWizardState state = ref.watch(setupWizardProvider);
    final SetupWizardNotifier notifier = ref.read(setupWizardProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.pageMargin),
          child: Column(
            children: [
              SizedBox(height: context.spacing.largePageBottomMargin),
              // Progress indicator
              SetupProgressIndicator(
                currentStep: state.currentStep + 1,
                totalSteps: SetupWizardState.totalSteps,
              ),
              const SizedBox(height: 60),

              // Success animation
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated success icon
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [context.colors.success, context.colors.success100],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: context.radius.largeIcon,
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.success.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _checkAnimation,
                            builder: (context, child) => CustomPaint(
                              painter: CheckmarkPainter(_checkAnimation.value),
                              size: const Size(120, 120),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Success title
                    const GradientText(
                      'Setup Complete!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    // Success message
                    Text(
                      'Welcome to Nebu! Your AI companion is ready to help you.',
                      style: TextStyle(
                        fontSize: 18,
                        color: context.colors.grey400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Summary section
              Expanded(flex: 2, child: _buildSummarySection(state)),

              // Action button
              CustomButton(
                text: 'Start Using Nebu',
                onPressed: () {
                  notifier.completeSetup();
                  context.go('/main');
                },
                isFullWidth: true,
                icon: Icons.rocket_launch,
              ),

              SizedBox(height: context.spacing.titleBottomMargin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(SetupWizardState state) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: context.radius.panel,
      border: Border.all(color: context.colors.grey700),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: context.radius.tile,
              ),
              child: Icon(
                Icons.summarize,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Setup Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildSummaryItem(
          icon: Icons.person,
          title: 'Profile',
          value: state.userName.isNotEmpty ? state.userName : 'Not set',
        ),

        _buildSummaryItem(
          icon: Icons.language,
          title: 'Language',
          value: _getLanguageName(state.selectedLanguage),
        ),

        _buildSummaryItem(
          icon: Icons.mic,
          title: 'Voice',
          value: state.voiceEnabled ? 'Enabled' : 'Disabled',
        ),

        _buildSummaryItem(
          icon: Icons.notifications,
          title: 'Notifications',
          value: state.notificationsEnabled ? 'Enabled' : 'Disabled',
        ),
      ],
    ),
  );

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: context.radius.smallInput,
          ),
          child: Icon(icon, color: context.colors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.grey400,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'pt':
        return 'Português';
      case 'it':
        return 'Italiano';
      default:
        return 'English';
    }
  }
}

class CheckmarkPainter extends CustomPainter {
  CheckmarkPainter(this.animationValue);
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw checkmark
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    final middleX = size.width * 0.45;
    final middleY = size.height * 0.65;
    final endX = size.width * 0.75;
    final endY = size.height * 0.35;

    path
      ..moveTo(startX, startY)
      ..lineTo(middleX, middleY)
      ..lineTo(endX, endY);

    final animatedPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      final length = pathMetric.length;
      final animatedLength = length * animationValue;
      final extractPath = pathMetric.extractPath(0, animatedLength);
      animatedPath.addPath(extractPath, Offset.zero);
    }

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is CheckmarkPainter &&
      oldDelegate.animationValue != animationValue;
}
