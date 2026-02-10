import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/toy.dart';
import '../providers/walkie_talkie_provider.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/push_to_talk_button.dart';

class WalkieTalkieScreen extends ConsumerStatefulWidget {
  const WalkieTalkieScreen({required this.toy, super.key});

  final Toy toy;

  @override
  ConsumerState<WalkieTalkieScreen> createState() => _WalkieTalkieScreenState();
}

class _WalkieTalkieScreenState extends ConsumerState<WalkieTalkieScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  Future<void> _initSession() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('walkie_talkie.mic_permission_required'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await ref.read(walkieTalkieProvider.notifier).startSession(widget.toy);
  }

  Future<void> _endSession() async {
    await ref.read(walkieTalkieProvider.notifier).endSession();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walkieTalkieProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _endSession();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('walkie_talkie.title'.tr())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Toy info
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 48,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.toy.name,
                  style: theme.textTheme.titleLarge,
                ),

                const SizedBox(height: 24),

                // Connection status
                ConnectionStatusIndicator(
                  phase: state.phase.name,
                  isRemoteConnected: state.isRemoteConnected,
                  remoteName: state.remoteParticipantName,
                ),

                const Spacer(),

                // Main content based on phase
                if (state.phase == WalkieTalkiePhase.connecting)
                  const CircularProgressIndicator()
                else if (state.phase == WalkieTalkiePhase.error)
                  _buildErrorState(state)
                else if (state.phase == WalkieTalkiePhase.connected)
                  PushToTalkButton(
                    onTalkStart: () =>
                        ref.read(walkieTalkieProvider.notifier).startTalking(),
                    onTalkEnd: () =>
                        ref.read(walkieTalkieProvider.notifier).stopTalking(),
                    isTalking: state.isTalking,
                    isEnabled: state.phase == WalkieTalkiePhase.connected,
                  ),

                const Spacer(),

                // End session button
                if (state.phase == WalkieTalkiePhase.connected ||
                    state.phase == WalkieTalkiePhase.error)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _endSession();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    label: Text(
                      'walkie_talkie.end_session'.tr(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WalkieTalkieState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 12),
      Text(
        'walkie_talkie.connection_failed'.tr(),
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () =>
            ref.read(walkieTalkieProvider.notifier).startSession(widget.toy),
        icon: const Icon(Icons.refresh),
        label: Text('walkie_talkie.retry'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryLight,
        ),
      ),
    ],
  );
}
