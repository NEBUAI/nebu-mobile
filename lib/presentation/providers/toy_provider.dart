import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/toy.dart';
import '../../data/services/toy_service.dart';
import 'api_provider.dart';

// Toy state
class ToyState {
  ToyState({
    this.toys = const [],
    this.currentToy,
    this.isLoading = false,
    this.error,
  });

  final List<Toy> toys;
  final Toy? currentToy;
  final bool isLoading;
  final String? error;

  ToyState copyWith({
    List<Toy>? toys,
    Toy? currentToy,
    bool? isLoading,
    String? error,
    bool clearCurrentToy = false,
    bool clearError = false,
  }) =>
      ToyState(
        toys: toys ?? this.toys,
        currentToy: clearCurrentToy ? null : (currentToy ?? this.currentToy),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

// Toy notifier
class ToyNotifier extends Notifier<ToyState> {
  late ToyService _toyService;

  @override
  ToyState build() {
    _toyService = ref.watch(toyServiceProvider);
    // Load toys automatically on init
    Future.microtask(loadMyToys);
    return ToyState(isLoading: true);
  }

  /// Cargar juguetes del usuario actual
  Future<void> loadMyToys() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final toys = await _toyService.getMyToys();
      state = state.copyWith(
        toys: toys,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Obtener un juguete por ID
  Future<Toy> getToyById(String id) async {
    try {
      final toy = await _toyService.getToyById(id);

      // Actualizar en la lista si existe
      final toys = [...state.toys];
      final index = toys.indexWhere((t) => t.id == id);
      if (index != -1) {
        toys[index] = toy;
        state = state.copyWith(toys: toys);
      }

      return toy;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Asignar un juguete
  Future<AssignToyResponse> assignToy({
    required String macAddress,
    required String userId,
    String? toyName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _toyService.assignToy(
        macAddress: macAddress,
        userId: userId,
        toyName: toyName,
      );

      if (response.toy != null) {
        final toys = [...state.toys, response.toy!];
        state = state.copyWith(
          toys: toys,
          currentToy: response.toy,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Actualizar un juguete
  Future<void> updateToy({
    required String id,
    String? name,
    ToyStatus? status,
    String? batteryLevel,
    String? signalStrength,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedToy = await _toyService.updateToy(
        id: id,
        name: name,
        status: status,
        batteryLevel: batteryLevel,
        signalStrength: signalStrength,
        notes: notes,
      );

      // Actualizar en la lista
      final toys = [...state.toys];
      final index = toys.indexWhere((toy) => toy.id == id);
      if (index != -1) {
        toys[index] = updatedToy;
      }

      // Actualizar current toy si es el mismo
      final currentToy = state.currentToy?.id == id ? updatedToy : state.currentToy;

      state = state.copyWith(
        toys: toys,
        currentToy: currentToy,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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

      // Actualizar en la lista
      final toys = [...state.toys];
      final index = toys.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        toys[index] = updatedToy;
      }

      // Actualizar current toy si es el mismo
      final currentToy = state.currentToy?.id == updatedToy.id ? updatedToy : state.currentToy;

      state = state.copyWith(
        toys: toys,
        currentToy: currentToy,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Eliminar un juguete
  Future<void> deleteToy(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _toyService.deleteToy(id);

      // Eliminar de la lista
      final toys = state.toys.where((toy) => toy.id != id).toList();

      // Limpiar current toy si es el mismo
      final clearCurrent = state.currentToy?.id == id;

      state = state.copyWith(
        toys: toys,
        isLoading: false,
        clearCurrentToy: clearCurrent,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Establecer el juguete actual
  void setCurrentToy(Toy? toy) {
    state = state.copyWith(
      currentToy: toy,
      clearCurrentToy: toy == null,
    );
  }

  /// Limpiar el error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpiar todo
  void clear() {
    state = ToyState();
  }
}

// Provider
final toyProvider = NotifierProvider<ToyNotifier, ToyState>(ToyNotifier.new);
