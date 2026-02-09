import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class VoiceSetupScreen extends ConsumerStatefulWidget {
  const VoiceSetupScreen({super.key});

  @override
  ConsumerState<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends ConsumerState<VoiceSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioRecorder _recorder = AudioRecorder();
  bool isRecording = false;
  bool isPlaying = false;

  final List<Map<String, dynamic>> voiceSettings = [
    {
      'title': 'Voice Recognition',
      'description': 'Enable voice commands and dictation',
      'icon': Icons.mic,
      'enabled': true,
    },
    {
      'title': 'Voice Synthesis',
      'description': 'Text-to-speech responses',
      'icon': Icons.volume_up,
      'enabled': true,
    },
    {
      'title': 'Wake Word Detection',
      'description': 'Activate with "Hey Nebu"',
      'icon': Icons.hearing,
      'enabled': false,
    },
    {
      'title': 'Noise Cancellation',
      'description': 'Reduce background noise',
      'icon': Icons.noise_control_off,
      'enabled': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SetupWizardState state = ref.watch(setupWizardProvider);
    final SetupWizardNotifier notifier = ref.read(setupWizardProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Progress indicator
              SetupProgressIndicator(
                currentStep: state.currentStep + 1,
                totalSteps: SetupWizardState.totalSteps,
              ),
              const SizedBox(height: 40),

              // Title
              const GradientText(
                'Voice Setup',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Configure your voice interaction preferences',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Voice test section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Voice test card
                      _buildVoiceTestCard(isDark),

                      const SizedBox(height: 32),

                      // Voice settings
                      _buildVoiceSettings(isDark),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Column(
                children: [
                  CustomButton(
                    text: 'Continue',
                    onPressed: notifier.nextStep,
                    isFullWidth: true,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: notifier.previousStep,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceTestCard(bool isDark) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: AppTheme.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryLight.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        const Text(
          'Test Your Voice',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Tap the microphone to test voice recognition',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Animated microphone button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: isRecording ? _scaleAnimation.value : 1.0,
            child: GestureDetector(
              onTapDown: (_) => _startRecording(),
              onTapUp: (_) => _stopRecording(),
              onTapCancel: _stopRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  size: 40,
                  color: isRecording ? Colors.red : AppTheme.primaryLight,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (isRecording)
          const Text(
            'Listening...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

        const SizedBox(height: 16),

        // Test playback button
        CustomButton(
          text: isPlaying ? 'Playing...' : 'Play Sample',
          onPressed: isPlaying ? null : _playSample,
          variant: ButtonVariant.secondary,
          isLoading: isPlaying,
          icon: Icons.play_arrow,
        ),
      ],
    ),
  );

  Widget _buildVoiceSettings(bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
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
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.settings_voice,
                color: AppTheme.primaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Voice Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ...voiceSettings.map(
          (setting) => _buildSettingTile(
            title: setting['title'] as String,
            description: setting['description'] as String,
            icon: setting['icon'] as IconData,
            enabled: setting['enabled'] as bool,
            isDark: isDark,
          ),
        ),
      ],
    ),
  );

  Widget _buildSettingTile({
    required String title,
    required String description,
    required IconData icon,
    required bool enabled,
    required bool isDark,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.primaryLight.withValues(alpha: 0.1)
                : (isDark ? Colors.grey[700] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? AppTheme.primaryLight : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: (value) {
            setState(() {
              // Update the specific setting
              for (final setting in voiceSettings) {
                if (setting['title'] == title) {
                  setting['enabled'] = value;
                  break;
                }
              }
            });
          },
          activeThumbColor: AppTheme.primaryLight,
        ),
      ],
    ),
  );

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _recorder.start(const RecordConfig(), path: '');
      if (!mounted) return;
      setState(() {
        isRecording = true;
      });
      _animationController.repeat(reverse: true);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start recording'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        isRecording = false;
      });
      _animationController
        ..stop()
        ..reset();

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice recognition test completed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception {
      if (!mounted) return;
      setState(() {
        isRecording = false;
      });
      _animationController
        ..stop()
        ..reset();
    }
  }

  void _playSample() {
    setState(() {
      isPlaying = true;
    });

    // TTS requires flutter_tts package — simulating playback for now
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample audio played!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    });
  }
}
