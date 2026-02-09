import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/activity.dart';
import '../../presentation/providers/activity_provider.dart';
import '../../presentation/providers/api_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../models/toy.dart';

/// Servicio para rastrear y crear actividades automáticamente
/// en eventos importantes del ciclo de vida de la aplicación
class ActivityTrackerService {
  ActivityTrackerService(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  /// Obtiene o genera un userId para el usuario actual
  /// Si el usuario está autenticado, usa su ID
  /// Si no, genera/recupera un UUID local
  Future<String> _getUserId() async {
    // ✅ Integrado con authProvider para obtener userId autenticado
    final authState = _ref.read(authProvider);

    // Si el usuario está autenticado, usar su ID real
    if (authState.hasValue && authState.value != null) {
      final user = authState.value!;
      _ref
          .read(loggerProvider)
          .d('🆔 [ACTIVITY_TRACKER] Using authenticated userId: ${user.id}');
      return user.id;
    }

    // Si no está autenticado, generar/recuperar UUID local
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    var localUserId = prefs.getString('local_user_id');

    if (localUserId == null) {
      localUserId = _uuid.v4();
      await prefs.setString('local_user_id', localUserId);
      _ref
          .read(loggerProvider)
          .i('🆔 [ACTIVITY_TRACKER] Generated new local userId: $localUserId');
    } else {
      _ref
          .read(loggerProvider)
          .d('🆔 [ACTIVITY_TRACKER] Using local userId: $localUserId');
    }

    return localUserId;
  }

  /// Registra una actividad de conexión de toy
  Future<void> trackToyConnection(Toy toy) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.connection,
            description: 'Connected to ${toy.name}',
            toyId: toy.id,
            metadata: {
              'toy_name': toy.name,
              'connection_type': 'bluetooth',
              'event': 'connected',
            },
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked toy connection: ${toy.name}');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking toy connection: $e');
    }
  }

  /// Registra una actividad de desconexión de toy
  Future<void> trackToyDisconnection(Toy toy) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.connection,
            description: 'Disconnected from ${toy.name}',
            toyId: toy.id,
            metadata: {
              'toy_name': toy.name,
              'connection_type': 'bluetooth',
              'event': 'disconnected',
            },
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked toy disconnection: ${toy.name}');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking toy disconnection: $e');
    }
  }

  /// Registra una actividad de comando de voz
  Future<void> trackVoiceCommand(String command, {String? toyId}) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.voiceCommand,
            description: 'Voice command: "$command"',
            toyId: toyId,
            metadata: {'command': command, 'command_length': command.length},
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked voice command: $command');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking voice command: $e');
    }
  }

  /// Registra una actividad de error
  Future<void> trackError(
    String errorMessage, {
    String? toyId,
    Map<String, dynamic>? errorDetails,
  }) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.error,
            description: errorMessage,
            toyId: toyId,
            metadata: {'error_type': 'system_error', ...?errorDetails},
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked error: $errorMessage');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking error activity: $e');
    }
  }

  /// Registra el inicio de una sesión de juego
  Future<void> trackPlaySessionStart(String toyId, {String? toyName}) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.play,
            description: 'Started playing with ${toyName ?? "toy"}',
            toyId: toyId,
            metadata: {'session_type': 'play', 'event': 'started'},
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked play session start');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking play session: $e');
    }
  }

  /// Registra una interacción general
  Future<void> trackInteraction(
    String description, {
    String? toyId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.interaction,
            description: description,
            toyId: toyId,
            metadata: metadata,
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked interaction: $description');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking interaction: $e');
    }
  }

  /// Registra una actualización del sistema
  Future<void> trackUpdate(
    String updateDescription, {
    String? toyId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.update,
            description: updateDescription,
            toyId: toyId,
            metadata: metadata,
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked update: $updateDescription');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking update: $e');
    }
  }

  /// Registra una conversación de chat
  Future<void> trackChatMessage(
    String message, {
    String? toyId,
    bool isUserMessage = true,
  }) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.chat,
            description: isUserMessage ? 'User said: "$message"' : 'AI replied',
            toyId: toyId,
            metadata: {
              'message_type': isUserMessage ? 'user' : 'ai',
              'message_length': message.length,
            },
          );

      _ref.read(loggerProvider).i('📊 [ACTIVITY_TRACKER] Tracked chat message');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking chat message: $e');
    }
  }

  /// Registra cuando el toy entra en modo sleep
  Future<void> trackSleep(String toyId, {String? toyName}) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.sleep,
            description: '${toyName ?? "Toy"} went to sleep',
            toyId: toyId,
            metadata: {'power_state': 'sleep'},
          );

      _ref.read(loggerProvider).i('📊 [ACTIVITY_TRACKER] Tracked sleep mode');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking sleep: $e');
    }
  }

  /// Registra cuando el toy despierta
  Future<void> trackWake(String toyId, {String? toyName}) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.wake,
            description: '${toyName ?? "Toy"} woke up',
            toyId: toyId,
            metadata: {'power_state': 'awake'},
          );

      _ref.read(loggerProvider).i('📊 [ACTIVITY_TRACKER] Tracked wake mode');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking wake: $e');
    }
  }

  /// Registra el completado del setup del usuario
  Future<void> trackSetupCompleted({
    required String childName,
    required String ageGroup,
    required String personality,
    bool isLocalSetup = false,
  }) async {
    try {
      final userId = await _getUserId();

      await _ref
          .read(activityNotifierProvider.notifier)
          .createActivity(
            userId: userId,
            type: ActivityType.interaction,
            description:
                'Setup completed for $childName (${isLocalSetup ? "local" : "connected"})',
            metadata: {
              'setup_type': isLocalSetup ? 'local' : 'connected',
              'child_name': childName,
              'age_group': ageGroup,
              'personality': personality,
              'event': 'setup_completed',
            },
          );

      _ref
          .read(loggerProvider)
          .i('📊 [ACTIVITY_TRACKER] Tracked setup completion for $childName');
    } on Exception catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [ACTIVITY_TRACKER] Error tracking setup completion: $e');
    }
  }
}

// Provider para el servicio de tracking
final activityTrackerServiceProvider = Provider<ActivityTrackerService>(
  ActivityTrackerService.new,
);
