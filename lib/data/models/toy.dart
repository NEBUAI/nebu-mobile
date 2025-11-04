import 'package:freezed_annotation/freezed_annotation.dart';

part 'toy.freezed.dart';
part 'toy.g.dart';

enum ToyStatus {
  @JsonValue('inactive')
  inactive,
  @JsonValue('active')
  active,
  @JsonValue('connected')
  connected,
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('error')
  error,
  @JsonValue('blocked')
  blocked,
}

@freezed
class Toy with _$Toy {
  const factory Toy({
    required String id,
    required String macAddress,
    required String name,
    required ToyStatus status,
    String? iotDeviceId,
    String? userId,
    String? model,
    String? manufacturer,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? batteryLevel,
    String? signalStrength,
    @Default(false) bool isActive,
    @Default(false) bool isConnected,
    @Default(false) bool needsAttention,
    DateTime? activatedAt,
    DateTime? lastSeenAt,
    DateTime? lastConnected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Toy;

  factory Toy.fromJson(Map<String, dynamic> json) => _$ToyFromJson(json);
}

@freezed
class CreateToyRequest with _$CreateToyRequest {
  const factory CreateToyRequest({
    required String macAddress,
    required String name,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
  }) = _CreateToyRequest;

  factory CreateToyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateToyRequestFromJson(json);
}

@freezed
class UpdateToyRequest with _$UpdateToyRequest {
  const factory UpdateToyRequest({
    String? name,
    ToyStatus? status,
    String? batteryLevel,
    String? signalStrength,
    String? notes,
  }) = _UpdateToyRequest;

  factory UpdateToyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateToyRequestFromJson(json);
}

@freezed
class ToysListResponse with _$ToysListResponse {
  const factory ToysListResponse({
    required List<Toy> toys,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _ToysListResponse;

  factory ToysListResponse.fromJson(Map<String, dynamic> json) =>
      _$ToysListResponseFromJson(json);
}

@freezed
class AssignToyRequest with _$AssignToyRequest {
  const factory AssignToyRequest({
    required String macAddress,
    required String userId,
    String? toyName,
  }) = _AssignToyRequest;

  factory AssignToyRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignToyRequestFromJson(json);
}

@freezed
class AssignToyResponse with _$AssignToyResponse {
  const factory AssignToyResponse({
    required bool success,
    String? message,
    Toy? toy,
  }) = _AssignToyResponse;

  factory AssignToyResponse.fromJson(Map<String, dynamic> json) =>
      _$AssignToyResponseFromJson(json);
}

@freezed
class UpdateToyStatusRequest with _$UpdateToyStatusRequest {
  const factory UpdateToyStatusRequest({
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) = _UpdateToyStatusRequest;

  factory UpdateToyStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateToyStatusRequestFromJson(json);
}
