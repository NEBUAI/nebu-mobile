import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/toy.dart';
import '../../data/services/toy_service.dart';
import 'api_provider.dart';

// Toy state provider using AsyncNotifier
final toyProvider = AsyncNotifierProvider<ToyNotifier, List<Toy>>(
  ToyNotifier.new,
);

class ToyNotifier extends AsyncNotifier<List<Toy>> {
  @override
  Future<List<Toy>> build() async {
    // Initialize with empty list, will be loaded when needed
    return [];
  }

  ToyService get _toyService => ref.read(toyServiceProvider);

  /// Load user's toys
  Future<void> loadMyToys() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final toys = await _toyService.getMyToys();
      ref.read(loggerProvider).d('Loaded ${toys.length} toys');
      return toys;
    });
  }

  /// Create/register a new toy
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
      final toy = await _toyService.createToy(
        iotDeviceId: iotDeviceId,
        name: name,
        userId: userId,
        model: model,
        manufacturer: manufacturer,
        status: status,
        firmwareVersion: firmwareVersion,
        capabilities: capabilities,
        settings: settings,
        notes: notes,
      );

      ref.read(loggerProvider).d('Toy created successfully: ${toy.name}');

      // Add to the list
      final currentState = state.value ?? [];
      state = AsyncValue.data([...currentState, toy]);

      return toy;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error creating toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Assign toy to user account
  Future<AssignToyResponse> assignToy({
    required String macAddress,
    required String userId,
    String? toyName,
  }) async {
    try {
      final response = await _toyService.assignToy(
        macAddress: macAddress,
        userId: userId,
        toyName: toyName,
      );

      ref.read(loggerProvider).d('Toy assigned successfully: ${response.toy?.name}');

      // Update the toy list
      if (response.toy != null) {
        final currentState = state.value ?? [];
        state = AsyncValue.data([...currentState, response.toy!]);
      }

      return response;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error assigning toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update toy connection status
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

      ref.read(loggerProvider).d('Toy status updated: ${updatedToy.name}');

      // Update in list
      final currentState = state.value ?? [];
      final index = currentState.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedToy;
        state = AsyncValue.data(newList);
      }
    } catch (e, st) {
      ref.read(loggerProvider).e('Error updating toy status: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Get a toy by ID
  Future<Toy> getToyById(String id) async {
    try {
      final toy = await _toyService.getToyById(id);
      ref.read(loggerProvider).d('Loaded toy: ${toy.name}');

      // Update in list if already exists
      final currentState = state.value ?? [];
      final index = currentState.indexWhere((t) => t.id == toy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = toy;
        state = AsyncValue.data(newList);
      } else {
        // Add to list if not exists
        state = AsyncValue.data([...currentState, toy]);
      }

      return toy;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error loading toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update toy information
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

      ref.read(loggerProvider).d('Toy updated: ${updatedToy.name}');

      // Update in list
      final currentState = state.value ?? [];
      final index = currentState.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedToy;
        state = AsyncValue.data(newList);
      }

      return updatedToy;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error updating toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a toy
  Future<void> deleteToy(String id) async {
    try {
      await _toyService.deleteToy(id);
      ref.read(loggerProvider).d('Toy deleted: $id');

      // Remove from list
      final currentState = state.value ?? [];
      state = AsyncValue.data(
        currentState.where((toy) => toy.id != id).toList(),
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Error deleting toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Clear all toys
  void clear() {
    state = const AsyncValue.data([]);
  }
}
