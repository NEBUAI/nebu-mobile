import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';

/// Servicio proxy para OpenAI - NUNCA expone API keys en el cliente
/// Todas las llamadas a OpenAI van a través del backend
class OpenAIProxyService {
  OpenAIProxyService({required Logger logger, required Dio dio})
    : _logger = logger,
      _dio = dio;

  final Logger _logger;
  final Dio _dio;

  /// Enviar mensaje de texto a través del backend
  Future<String> sendMessage({
    required String message,
    required String language,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      _logger.d('📤 Enviando mensaje a OpenAI (vía backend)...');

      final response = await _dio.post<Map<String, dynamic>>(
        '${Config.apiBaseUrl}/openai/chat',
        data: {
          'message': message,
          'language': language,
          'conversationHistory': conversationHistory ?? [],
        },
      );

      if (response.statusCode == 200) {
        final result = response.data!['result'] as String;
        _logger.i('✅ Respuesta recibida de OpenAI (vía backend)');
        return result;
      }

      throw Exception('OpenAI error: ${response.statusCode}');
    } on DioException catch (e) {
      _logger.e('❌ Error en OpenAI proxy: ${e.message}');
      rethrow;
    }
  }

  /// Generar audio de respuesta a través del backend
  Future<List<int>> generateSpeech({
    required String text,
    required String voice,
  }) async {
    try {
      _logger.d('🔊 Generando audio (vía backend)...');

      final response = await _dio.post<List<int>>(
        '${Config.apiBaseUrl}/openai/speech',
        data: {'text': text, 'voice': voice},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Audio generado exitosamente (vía backend)');
        return response.data!;
      }

      throw Exception('Speech generation error: ${response.statusCode}');
    } on DioException catch (e) {
      _logger.e('❌ Error generando audio: ${e.message}');
      rethrow;
    }
  }

  /// Procesar audio a través del backend
  Future<String> processAudio({
    required List<int> audioBytes,
    required String language,
  }) async {
    try {
      _logger.d('📊 Procesando audio (vía backend)...');

      final response = await _dio.post<Map<String, dynamic>>(
        '${Config.apiBaseUrl}/openai/transcribe',
        data: FormData.fromMap({
          'audio': MultipartFile.fromBytes(audioBytes, filename: 'audio.wav'),
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final transcription = response.data!['transcription'] as String;
        _logger.i('✅ Audio transcrito exitosamente (vía backend)');
        return transcription;
      }

      throw Exception('Audio processing error: ${response.statusCode}');
    } on DioException catch (e) {
      _logger.e('❌ Error procesando audio: ${e.message}');
      rethrow;
    }
  }
}
