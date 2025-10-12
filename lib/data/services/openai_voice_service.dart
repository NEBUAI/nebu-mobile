import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuración del agente de voz
class VoiceAgentConfig {

  const VoiceAgentConfig({
    required this.apiKey,
    this.model = 'gpt-4o',
    this.voice = 'nova',
    this.language = 'es',
  });
  final String apiKey;
  final String model;
  final String voice;
  final String language;
}

/// Mensaje de conversación
class ConversationMessage {

  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.audioUrl,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        audioUrl: json['audioUrl'] as String?,
      );
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final String? audioUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'audioUrl': audioUrl,
  };
}

/// Estados del agente de voz
enum VoiceAgentStatus {
  idle,
  listening,
  processing,
  speaking,
  error,
}

/// Servicio de OpenAI Voice Agent
class OpenAIVoiceService {

  OpenAIVoiceService({
    required Logger logger,
    required Dio dio,
  }) : _logger = logger,
       _dio = dio,
       _recorder = AudioRecorder(),
       _audioPlayer = AudioPlayer();
  final Logger _logger;
  final Dio _dio;
  final AudioRecorder _recorder;
  final AudioPlayer _audioPlayer;

  VoiceAgentConfig? _config;
  bool _isInitialized = false;
  VoiceAgentStatus _status = VoiceAgentStatus.idle;
  final List<ConversationMessage> _conversation = [];
  
  // Streams para notificaciones
  final StreamController<VoiceAgentStatus> _statusController = 
      StreamController<VoiceAgentStatus>.broadcast();
  final StreamController<ConversationMessage> _messageController = 
      StreamController<ConversationMessage>.broadcast();

  // Callbacks
  void Function(ConversationMessage)? _onMessageCallback;
  void Function(VoiceAgentStatus)? _onStatusCallback;

  /// Inicializar el servicio
  Future<void> initialize(VoiceAgentConfig config) async {
    try {
      _config = config;
      
      // Configurar Dio con la API key
      _dio.options.headers['Authorization'] = 'Bearer ${config.apiKey}';
      _dio.options.headers['Content-Type'] = 'application/json';
      
      // Solicitar permisos de audio
      await _requestAudioPermissions();
      
      // Configurar audio player
      await _audioPlayer.setVolume(1);
      
      _isInitialized = true;
      _logger.i('OpenAI Voice Service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing OpenAI Voice Service: $e');
      rethrow;
    }
  }

  /// Solicitar permisos de audio
  Future<void> _requestAudioPermissions() async {
    final microphonePermission = await Permission.microphone.request();
    if (!microphonePermission.isGranted) {
      throw Exception('Microphone permission not granted');
    }
  }

  /// Cambiar estado y notificar
  void _setStatus(VoiceAgentStatus status) {
    _status = status;
    _statusController.add(status);
    _onStatusCallback?.call(status);
    _logger.d('Voice agent status changed to: $status');
  }

  /// Agregar mensaje a la conversación
  void _addMessage(ConversationMessage message) {
    _conversation.add(message);
    _messageController.add(message);
    _onMessageCallback?.call(message);
  }

  /// Guardar conversación en almacenamiento local
  Future<void> _saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationJson = _conversation.map((m) => m.toJson()).toList();
      await prefs.setString('voice_conversation', jsonEncode(conversationJson));
    } catch (e) {
      _logger.e('Error saving conversation: $e');
    }
  }

  /// Cargar conversación desde almacenamiento local
  // TODO(dev): Implement conversation loading when needed
  // ignore: unused_element
  Future<void> _loadConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationString = prefs.getString('voice_conversation');
      if (conversationString != null) {
        final conversationJson = jsonDecode(conversationString) as List;
        _conversation.clear();
        _conversation.addAll(
          conversationJson.map((json) => ConversationMessage.fromJson(json as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      _logger.e('Error loading conversation: $e');
    }
  }

  /// Iniciar grabación de voz
  Future<void> startListening() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }

    if (_status == VoiceAgentStatus.listening) {
      return;
    }

    try {
      _setStatus(VoiceAgentStatus.listening);
      
      // Verificar permisos
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        await _requestAudioPermissions();
      }

      // Iniciar grabación
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
        ),
        path: '/tmp/voice_input.wav',
      );

      _logger.i('Started listening for voice input');
    } catch (e) {
      _logger.e('Error starting listening: $e');
      _setStatus(VoiceAgentStatus.error);
      rethrow;
    }
  }

  /// Detener grabación y procesar
  Future<void> stopListening() async {
    if (_status != VoiceAgentStatus.listening) {
      return;
    }

    try {
      _setStatus(VoiceAgentStatus.processing);
      
      // Detener grabación
      final audioPath = await _recorder.stop();
      if (audioPath == null) {
        throw Exception('No audio recorded');
      }

      // Procesar audio con OpenAI
      await _processAudioWithOpenAI(audioPath);
    } catch (e) {
      _logger.e('Error stopping listening: $e');
      _setStatus(VoiceAgentStatus.error);
      rethrow;
    }
  }

  /// Procesar audio con OpenAI
  Future<void> _processAudioWithOpenAI(String audioPath) async {
    try {
      // Leer archivo de audio
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found');
      }

      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      // Preparar conversación para contexto
      final conversationMessages = _conversation
          .map((msg) => {
                'role': msg.role,
                'content': msg.content,
              })
          .toList();

      // Llamada a OpenAI API
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': _config!.model,
          'messages': [
            {
              'role': 'system',
              'content': 'Eres Nebu, un asistente de IA útil y amigable. Responde en ${_config!.language}.',
            },
            ...conversationMessages,
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Transcribe este audio y responde a la pregunta o comentario.',
                },
                {
                  'type': 'input',
                  'input': {
                    'audio': 'data:audio/wav;base64,$audioBase64',
                  },
                },
              ],
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      final data = response.data!;
      final assistantMessage = data['choices'][0]['message']['content'] as String;
      
      // Crear mensaje del usuario (transcripción)
      final userMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'user',
        content: 'Transcripción de audio', // En una implementación real, obtendrías la transcripción
        timestamp: DateTime.now(),
        audioUrl: audioPath,
      );

      // Crear mensaje del asistente
      final assistantMsg = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: assistantMessage,
        timestamp: DateTime.now(),
      );

      _addMessage(userMessage);
      _addMessage(assistantMsg);
      
      // Guardar conversación
      await _saveConversation();
      
      // Generar audio de respuesta
      await _generateAndPlayAudio(assistantMessage);
      
    } catch (e) {
      _logger.e('Error processing audio with OpenAI: $e');
      _setStatus(VoiceAgentStatus.error);
      rethrow;
    }
  }

  /// Generar y reproducir audio de respuesta
  Future<void> _generateAndPlayAudio(String text) async {
    try {
      _setStatus(VoiceAgentStatus.speaking);

      // Generar audio con OpenAI TTS
      final response = await _dio.post<List<int>>(
        'https://api.openai.com/v1/audio/speech',
        data: {
          'model': 'tts-1',
          'input': text,
          'voice': _config!.voice,
          'response_format': 'mp3',
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      // Guardar audio temporal
      const audioPath = '/tmp/voice_response.mp3';
      final audioFile = File(audioPath);
      await audioFile.writeAsBytes(response.data!);

      // Reproducir audio
      await _audioPlayer.setFilePath(audioPath);
      await _audioPlayer.play();

      // Esperar a que termine la reproducción
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      _setStatus(VoiceAgentStatus.idle);
    } catch (e) {
      _logger.e('Error generating and playing audio: $e');
      _setStatus(VoiceAgentStatus.error);
      rethrow;
    }
  }

  /// Enviar mensaje de texto
  Future<void> sendTextMessage(String text) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }

    try {
      _setStatus(VoiceAgentStatus.processing);

      final conversationMessages = _conversation
          .map((msg) => {
                'role': msg.role,
                'content': msg.content,
              })
          .toList();

      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': _config!.model,
          'messages': [
            {
              'role': 'system',
              'content': 'Eres Nebu, un asistente de IA útil y amigable. Responde en ${_config!.language}.',
            },
            ...conversationMessages,
            {
              'role': 'user',
              'content': text,
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      final data = response.data!;
      final assistantMessage = data['choices'][0]['message']['content'] as String;

      // Crear mensajes
      final userMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
      );

      final assistantMsg = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: assistantMessage,
        timestamp: DateTime.now(),
      );

      _addMessage(userMessage);
      _addMessage(assistantMsg);
      
      await _saveConversation();
      
      // Generar audio de respuesta
      await _generateAndPlayAudio(assistantMessage);
      
    } catch (e) {
      _logger.e('Error sending text message: $e');
      _setStatus(VoiceAgentStatus.error);
      rethrow;
    }
  }

  /// Obtener historial de conversación
  List<ConversationMessage> get conversation => List.unmodifiable(_conversation);

  /// Obtener estado actual
  VoiceAgentStatus get status => _status;

  /// Stream de estados
  Stream<VoiceAgentStatus> get statusStream => _statusController.stream;

  /// Stream de mensajes
  Stream<ConversationMessage> get messageStream => _messageController.stream;

  /// Establecer callback de mensajes
  void setOnMessageCallback(void Function(ConversationMessage) callback) {
    _onMessageCallback = callback;
  }

  /// Establecer callback de estado
  void setOnStatusCallback(void Function(VoiceAgentStatus) callback) {
    _onStatusCallback = callback;
  }

  /// Limpiar conversación
  Future<void> clearConversation() async {
    _conversation.clear();
    await _saveConversation();
    _logger.i('Conversation cleared');
  }

  /// Cerrar servicio
  Future<void> dispose() async {
    await _recorder.dispose();
    await _audioPlayer.dispose();
    await _statusController.close();
    await _messageController.close();
    _logger.i('OpenAI Voice Service disposed');
  }
}
