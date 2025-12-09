import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/toy.dart';
import 'api_service.dart';

class ToyService {
  ToyService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Registrar un nuevo juguete
  Future<Toy> createToy({
    required String iotDeviceId,
    required String name,
    required String userId,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
  }) async {
    try {
      _logger.d('Creating toy: $name');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/toys',
        data: {
          'iotDeviceId': iotDeviceId,
          'name': name,
          'userId': userId,
          if (model != null) 'model': model,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (status != null) 'status': status.name,
          if (firmwareVersion != null) 'firmwareVersion': firmwareVersion,
          if (capabilities != null) 'capabilities': capabilities,
          if (settings != null) 'settings': settings,
          if (notes != null) 'notes': notes,
        },
      );

      _logger.d('Toy created successfully: ${response['id']}');
      return Toy.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error creating toy: ${e.message}');
      throw Exception('Error al registrar el juguete: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error creating toy: $e');
      throw Exception('Error inesperado al registrar el juguete');
    }
  }

  /// Obtener juguetes del usuario actual
  Future<List<Toy>> getMyToys() async {
    try {
      _logger.d('🎮 [TOY_SERVICE] Fetching my toys from /toys/my-toys');

      final response = await _apiService.get<List<dynamic>>('/toys/my-toys');

      _logger.d('🎮 [TOY_SERVICE] Raw response type: ${response.runtimeType}');
      _logger.d('🎮 [TOY_SERVICE] Response: $response');

      if (response.isEmpty) {
        _logger.i('🎮 [TOY_SERVICE] No toys found, returning empty list');
        return [];
      }

      _logger.d('🎮 [TOY_SERVICE] First toy raw data: ${response.first}');

      final toys = <Toy>[];
      for (var i = 0; i < response.length; i++) {
        try {
          final json = response[i] as Map<String, dynamic>;
          _logger.d('🎮 [TOY_SERVICE] Parsing toy $i: ${json['name'] ?? 'unknown'}');
          final toy = Toy.fromJson(json);
          toys.add(toy);
        } catch (e, stack) {
          _logger.e('🎮 [TOY_SERVICE] Error parsing toy $i: $e');
          _logger.e('🎮 [TOY_SERVICE] Stack trace: $stack');
          _logger.e('🎮 [TOY_SERVICE] Raw data: ${response[i]}');
          // Continue parsing other toys instead of failing completely
        }
      }

      _logger.i('🎮 [TOY_SERVICE] Successfully parsed ${toys.length} toys');
      return toys;
    } on DioException catch (e) {
      _logger.e('🎮 [TOY_SERVICE] DioException: ${e.message}');
      _logger.e('🎮 [TOY_SERVICE] Status code: ${e.response?.statusCode}');
      _logger.e('🎮 [TOY_SERVICE] Response data: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        _logger.i('🎮 [TOY_SERVICE] 404 - No toys found, returning empty list');
        return [];
      }
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }
      throw Exception('Error al obtener los juguetes: ${e.message}');
    } catch (e, stack) {
      _logger.e('🎮 [TOY_SERVICE] Unexpected error: $e');
      _logger.e('🎮 [TOY_SERVICE] Stack trace: $stack');
      throw Exception('Error inesperado al obtener los juguetes: $e');
    }
  }

  /// Asignar un juguete existente a la cuenta del usuario
  Future<AssignToyResponse> assignToy({
    required String macAddress,
    required String userId,
    String? toyName,
  }) async {
    try {
      _logger.d('Assigning toy with MAC: $macAddress');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/toys/assign',
        data: {
          'macAddress': macAddress,
          'userId': userId,
          if (toyName != null) 'toyName': toyName,
        },
      );

      _logger.d('Toy assigned successfully');
      return AssignToyResponse.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error assigning toy: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Juguete no encontrado con ese MAC address');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Este juguete ya está asignado a otro usuario');
      }
      throw Exception('Error al asignar el juguete: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error assigning toy: $e');
      throw Exception('Error inesperado al asignar el juguete');
    }
  }

  /// Actualizar el estado de conexión del juguete
  Future<Toy> updateToyConnectionStatus({
    required String macAddress,
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) async {
    try {
      _logger.d('Updating toy connection status: $macAddress');

      final response = await _apiService.patch<Map<String, dynamic>>(
        '/toys/connection/$macAddress',
        data: {
          'status': status.name,
          if (batteryLevel != null) 'batteryLevel': batteryLevel,
          if (signalStrength != null) 'signalStrength': signalStrength,
        },
      );

      _logger.d('Toy status updated successfully');
      return Toy.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error updating toy status: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Juguete no encontrado');
      }
      throw Exception('Error al actualizar el estado: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error updating toy status: $e');
      throw Exception('Error inesperado al actualizar el estado');
    }
  }

  /// Obtener un juguete por su ID
  Future<Toy> getToyById(String id) async {
    try {
      _logger.d('Fetching toy by ID: $id');

      final response = await _apiService.get<Map<String, dynamic>>('/toys/$id');

      _logger.d('Toy fetched successfully');
      return Toy.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching toy: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Juguete no encontrado');
      }
      throw Exception('Error al obtener el juguete: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error fetching toy: $e');
      throw Exception('Error inesperado al obtener el juguete');
    }
  }

  /// Actualizar información de un juguete
  Future<Toy> updateToy({
    required String id,
    String? name,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
  }) async {
    try {
      _logger.d('Updating toy: $id');

      final response = await _apiService.patch<Map<String, dynamic>>(
        '/toys/$id',
        data: {
          if (name != null) 'name': name,
          if (model != null) 'model': model,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (status != null) 'status': status.name,
          if (firmwareVersion != null) 'firmwareVersion': firmwareVersion,
          if (capabilities != null) 'capabilities': capabilities,
          if (settings != null) 'settings': settings,
          if (notes != null) 'notes': notes,
        },
      );

      _logger.d('Toy updated successfully');
      return Toy.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error updating toy: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Juguete no encontrado');
      }
      throw Exception('Error al actualizar el juguete: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error updating toy: $e');
      throw Exception('Error inesperado al actualizar el juguete');
    }
  }

  /// Eliminar un juguete
  Future<void> deleteToy(String id) async {
    try {
      _logger.d('Deleting toy: $id');

      await _apiService.delete<void>('/toys/$id');

      _logger.d('Toy deleted successfully');
    } on DioException catch (e) {
      _logger.e('Error deleting toy: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Juguete no encontrado');
      } else if (e.response?.statusCode == 409) {
        throw Exception('No se puede eliminar el juguete porque está en uso');
      }
      throw Exception('Error al eliminar el juguete: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error deleting toy: $e');
      throw Exception('Error inesperado al eliminar el juguete');
    }
  }
}
