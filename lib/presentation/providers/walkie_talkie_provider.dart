import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/toy.dart';
import '../../data/services/device_token_service.dart';
import '../../data/services/livekit_service.dart';
import '../../data/services/voice_session_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

enum WalkieTalkiePhase { idle, connecting, connected, error, disconnecting }

class WalkieTalkieState {
  const WalkieTalkieState({
    this.phase = WalkieTalkiePhase.idle,
    this.isTalking = false,
    this.isRemoteConnected = false,
    this.remoteParticipantName,
    this.sessionId,
    this.roomName,
    this.error,
  });

  final WalkieTalkiePhase phase;
  final bool isTalking;
  final bool isRemoteConnected;
  final String? remoteParticipantName;
  final String? sessionId;
  final String? roomName;
  final String? error;

  WalkieTalkieState copyWith({
    WalkieTalkiePhase? phase,
    bool? isTalking,
    bool? isRemoteConnected,
    String? remoteParticipantName,
    String? sessionId,
    String? roomName,
    String? error,
  }) => WalkieTalkieState(
    phase: phase ?? this.phase,
    isTalking: isTalking ?? this.isTalking,
    isRemoteConnected: isRemoteConnected ?? this.isRemoteConnected,
    remoteParticipantName: remoteParticipantName ?? this.remoteParticipantName,
    sessionId: sessionId ?? this.sessionId,
    roomName: roomName ?? this.roomName,
    error: error,
  );
}

final walkieTalkieProvider =
    NotifierProvider<WalkieTalkieNotifier, WalkieTalkieState>(
  WalkieTalkieNotifier.new,
);

class WalkieTalkieNotifier extends Notifier<WalkieTalkieState> {
  late LiveKitService _liveKitService;
  late DeviceTokenService _deviceTokenService;
  late VoiceSessionService _voiceSessionService;

  StreamSubscription<LiveKitConnectionStatus>? _statusSub;
  StreamSubscription<dynamic>? _participantsSub;

  @override
  WalkieTalkieState build() {
    _liveKitService = ref.read(liveKitServiceProvider);
    _deviceTokenService = ref.read(deviceTokenServiceProvider);
    _voiceSessionService = ref.read(voiceSessionServiceProvider);

    ref.onDispose(_cleanup);

    return const WalkieTalkieState();
  }

  Future<void> startSession(Toy toy) async {
    if (toy.iotDeviceId == null) {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'no_iot_device',
      );
      return;
    }

    state = state.copyWith(phase: WalkieTalkiePhase.connecting);

    try {
      // 1. Get LiveKit token for this device
      final tokenResponse = await _deviceTokenService.requestDeviceToken(
        toy.iotDeviceId!,
      );

      // 2. Create voice session on backend
      final user = ref.read(authProvider).value;
      final sessionResponse = await _voiceSessionService.createSession(
        userId: user?.id ?? 'anonymous',
        sessionToken: tokenResponse.accessToken,
        roomName: tokenResponse.roomName,
      );
      final sessionId = sessionResponse['id'] as String?;

      // 3. Connect to LiveKit room
      await _liveKitService.connect(
        LiveKitConfig(
          roomName: tokenResponse.roomName,
          participantName: user?.firstName ?? user?.id ?? 'parent',
          token: tokenResponse.accessToken,
        ),
      );

      // 4. Listen to status and participant changes
      _statusSub = _liveKitService.statusStream.listen(_onStatusChanged);
      _participantsSub = _liveKitService.participantsStream.listen((participants) {
        state = state.copyWith(
          isRemoteConnected: participants.isNotEmpty,
          remoteParticipantName: participants.isNotEmpty
              ? participants.first.identity
              : null,
        );
      });

      state = state.copyWith(
        phase: WalkieTalkiePhase.connected,
        sessionId: sessionId,
        roomName: tokenResponse.roomName,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: e.toString(),
      );
    }
  }

  void _onStatusChanged(LiveKitConnectionStatus status) {
    if (status == LiveKitConnectionStatus.disconnected &&
        state.phase == WalkieTalkiePhase.connected) {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'connection_lost',
      );
    }
  }

  Future<void> startTalking() async {
    if (state.phase != WalkieTalkiePhase.connected) {
      return;
    }
    state = state.copyWith(isTalking: true);
    await _liveKitService.setMicrophoneEnabled(enabled: true);
  }

  Future<void> stopTalking() async {
    state = state.copyWith(isTalking: false);
    await _liveKitService.setMicrophoneEnabled(enabled: false);
  }

  Future<void> endSession() async {
    state = state.copyWith(phase: WalkieTalkiePhase.disconnecting);

    try {
      await _liveKitService.setMicrophoneEnabled(enabled: false);
    } on Exception catch (_) {}

    try {
      await _liveKitService.disconnect();
    } on Exception catch (_) {}

    if (state.sessionId != null) {
      try {
        await _voiceSessionService.endSession(state.sessionId!);
      } on Exception catch (_) {}
    }

    _cleanup();
    state = const WalkieTalkieState();
  }

  void _cleanup() {
    _statusSub?.cancel();
    _participantsSub?.cancel();
    _statusSub = null;
    _participantsSub = null;
  }
}
