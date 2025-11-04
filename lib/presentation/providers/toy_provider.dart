import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../data/models/toy.dart';
import '../../data/services/toy_service.dart';

class ToyProvider extends ChangeNotifier {
  ToyProvider({
    required ToyService toyService,
    required Logger logger,
  })  : _toyService = toyService,
        _logger = logger;

  final ToyService _toyService;
  final Logger _logger;

  List<Toy> _toys = [];
  bool _isLoading = false;
  String? _error;
  Toy? _currentToy;

  List<Toy> get toys => _toys;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Toy? get currentToy => _currentToy;

  /// Cargar juguetes del usuario
  Future<void> loadMyToys() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _toys = await _toyService.getMyToys();
      _logger.d('Loaded ${_toys.length} toys');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading toys: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Asignar juguete a la cuenta del usuario
  Future<AssignToyResponse> assignToy({
    required String macAddress,
    required String userId,
    String? toyName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _toyService.assignToy(
        macAddress: macAddress,
        userId: userId,
        toyName: toyName,
      );

      _logger.d('Toy assigned successfully: ${response.toy?.name}');

      // Actualizar la lista de juguetes
      if (response.toy != null) {
        _toys.add(response.toy!);
        _currentToy = response.toy;
      }

      _isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      _logger.e('Error assigning toy: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Actualizar estado de conexión del juguete
  Future<void> updateToyConnectionStatus({
    required String macAddress,
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) async {
    try {
      final updatedToy = await _toyService.updateToyConnectionStatus(
        macAddress: macAddress,
        status: status,
        batteryLevel: batteryLevel,
        signalStrength: signalStrength,
      );

      _logger.d('Toy status updated: ${updatedToy.name}');

      // Actualizar en la lista
      final index = _toys.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        _toys[index] = updatedToy;
        if (_currentToy?.id == updatedToy.id) {
          _currentToy = updatedToy;
        }
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error updating toy status: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Obtener un juguete por su ID
  Future<Toy> getToyById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final toy = await _toyService.getToyById(id);
      _logger.d('Loaded toy: ${toy.name}');

      // Actualizar currentToy si es necesario
      _currentToy = toy;

      // Actualizar en la lista si ya existe
      final index = _toys.indexWhere((t) => t.id == toy.id);
      if (index != -1) {
        _toys[index] = toy;
      }

      _isLoading = false;
      notifyListeners();

      return toy;
    } catch (e) {
      _logger.e('Error loading toy: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedToy = await _toyService.updateToy(
        id: id,
        name: name,
        model: model,
        manufacturer: manufacturer,
        status: status,
        firmwareVersion: firmwareVersion,
        capabilities: capabilities,
        settings: settings,
        notes: notes,
      );

      _logger.d('Toy updated: ${updatedToy.name}');

      // Actualizar en la lista
      final index = _toys.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        _toys[index] = updatedToy;
      }

      // Actualizar currentToy si es el mismo
      if (_currentToy?.id == updatedToy.id) {
        _currentToy = updatedToy;
      }

      _isLoading = false;
      notifyListeners();

      return updatedToy;
    } catch (e) {
      _logger.e('Error updating toy: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Eliminar un juguete
  Future<void> deleteToy(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _toyService.deleteToy(id);
      _logger.d('Toy deleted: $id');

      // Eliminar de la lista
      _toys.removeWhere((toy) => toy.id == id);

      // Limpiar currentToy si es el mismo
      if (_currentToy?.id == id) {
        _currentToy = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error deleting toy: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Establecer el juguete actual
  void setCurrentToy(Toy? toy) {
    _currentToy = toy;
    notifyListeners();
  }

  /// Limpiar el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Limpiar todo
  void clear() {
    _toys = [];
    _currentToy = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
