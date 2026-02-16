import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

              // App logo/icon placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colors.primary, context.colors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: context.radius.tag,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  size: 60,
                  color: context.colors.textOnFilled,
                ),
              ),

              SizedBox(height: context.spacing.largePageBottomMargin),

              // Welcome title
              const GradientText(
                'Welcome to Nebu',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              // Subtitle
              Text(
                'Your AI-powered companion for productivity and creativity',
                style: TextStyle(
                  fontSize: 18,
                  color: context.colors.grey500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Features list
              Expanded(
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.mic,
                      title: 'Voice Commands',
                      description: 'Control your app with natural speech',
                    ),
                    SizedBox(height: context.spacing.panelPadding),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.psychology,
                      title: 'AI Assistant',
                      description: 'Get intelligent help and suggestions',
                    ),
                    SizedBox(height: context.spacing.panelPadding),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.notifications,
                      title: 'Smart Notifications',
                      description: 'Stay updated with personalized alerts',
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  CustomButton(
                    text: 'Get Started',
                    onPressed: notifier.nextStep,
                    isFullWidth: true,
                    icon: Icons.arrow_forward,
                  ),
                  SizedBox(height: context.spacing.sectionTitleBottomMargin),
                  TextButton(
                    onPressed: () => context.go('/main'),
                    child: Text(
                      'Skip Setup',
                      style: TextStyle(
                        color: context.colors.grey500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing.titleBottomMargin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) => Row(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: context.radius.tile,
        ),
        child: Icon(icon, color: context.colors.primary, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.grey500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
