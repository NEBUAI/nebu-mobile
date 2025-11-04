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
