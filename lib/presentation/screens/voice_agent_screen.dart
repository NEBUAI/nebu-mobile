import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VoiceAgentScreen extends StatelessWidget {
  const VoiceAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Agent'),
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
                Icons.mic,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Tap to speak',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Voice agent functionality coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
