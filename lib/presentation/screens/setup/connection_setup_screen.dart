import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ConnectionSetupScreen extends StatelessWidget {
  const ConnectionSetupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: AppTheme.primaryGradientDecoration,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress indicator
                  _buildProgressIndicator(1, 7),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Connect Your Device',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Let\'s connect your Nebu toy to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Connection icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bluetooth_searching,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next button
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppConstants.routeToyNameSetup);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  TextButton(
                    onPressed: () => context.go(AppConstants.routeHome),
                    child: Text(
                      'Skip Setup',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildProgressIndicator(int current, int total) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          total,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index < current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index < current
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
}
