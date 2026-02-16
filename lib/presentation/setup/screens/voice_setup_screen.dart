import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_colors.dart';
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
      'title': 'voice_setup.voice_recognition',
      'description': 'voice_setup.voice_recognition_desc',
      'icon': Icons.mic,
      'enabled': true,
    },
    {
      'title': 'voice_setup.voice_synthesis',
      'description': 'voice_setup.voice_synthesis_desc',
      'icon': Icons.volume_up,
      'enabled': true,
    },
    {
      'title': 'voice_setup.wake_word',
      'description': 'voice_setup.wake_word_desc',
      'icon': Icons.hearing,
      'enabled': false,
    },
    {
      'title': 'voice_setup.noise_cancellation',
      'description': 'voice_setup.noise_cancellation_desc',
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

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
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
              GradientText(
                'voice_setup.title'.tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'voice_setup.subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.grey400,
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
                      _buildVoiceTestCard(),

                      const SizedBox(height: 32),

                      // Voice settings
                      _buildVoiceSettings(),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Column(
                children: [
                  CustomButton(
                    text: 'common.continue'.tr(),
                    onPressed: notifier.nextStep,
                    isFullWidth: true,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: notifier.previousStep,
                    child: Text(
                      'common.back'.tr(),
                      style: TextStyle(
                        color: context.colors.grey400,
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

  Widget _buildVoiceTestCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [context.colors.primary, context.colors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: context.colors.primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          'voice_setup.test_your_voice'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.colors.textOnFilled,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'voice_setup.test_hint'.tr(),
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textOnFilled.withValues(alpha: 0.8),
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
                  color: context.colors.bgPrimary,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.textNormal.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  size: 40,
                  color: isRecording ? context.colors.error : context.colors.primary,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (isRecording)
          Text(
            'voice_setup.listening'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: context.colors.textOnFilled,
              fontWeight: FontWeight.w500,
            ),
          ),

        const SizedBox(height: 16),

        // Test playback button
        CustomButton(
          text: isPlaying ? 'voice_setup.playing'.tr() : 'voice_setup.play_sample'.tr(),
          onPressed: isPlaying ? null : _playSample,
          variant: ButtonVariant.secondary,
          isLoading: isPlaying,
          icon: Icons.play_arrow,
        ),
      ],
    ),
  );

  Widget _buildVoiceSettings() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings_voice,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'voice_setup.voice_settings'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? context.colors.primary.withValues(alpha: 0.1)
                : context.colors.grey700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? context.colors.primary : context.colors.grey400,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.grey400,
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
          activeThumbColor: context.colors.primary,
        ),
      ],
    ),
  );

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('voice_setup.mic_permission_required'.tr()),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      await _recorder.start(const RecordConfig(), path: '');
      if (!mounted) {
        return;
      }
      setState(() {
        isRecording = true;
      });
      unawaited(_animationController.repeat(reverse: true));
    } on Exception {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('voice_setup.recording_failed'.tr()),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        isRecording = false;
      });
      _animationController
        ..stop()
        ..reset();

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('voice_setup.test_completed'.tr()),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } on Exception {
      if (!mounted) {
        return;
      }
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
    unawaited(Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('voice_setup.sample_played'.tr()),
            backgroundColor: context.colors.info,
          ),
        );
      }
    }));
  }
}
