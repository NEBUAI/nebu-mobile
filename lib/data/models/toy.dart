import 'package:freezed_annotation/freezed_annotation.dart';

part 'toy.freezed.dart';
part 'toy.g.dart';

enum ToyStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('maintenance')
  maintenance,
}

@freezed
class Toy with _$Toy {
  const Toy._();
  
  const factory Toy({
    required String id,
    required String iotDeviceId,
    required String name,
    required ToyStatus status,
    required String userId,
    String? model,
    String? manufacturer,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? batteryLevel,
    String? signalStrength,
    DateTime? lastConnected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Toy;

  factory Toy.fromJson(Map<String, dynamic> json) => _$ToyFromJson(json);
}

@freezed
class CreateToyRequest with _$CreateToyRequest {
  const CreateToyRequest._();
  
  const factory CreateToyRequest({
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
  }) = _CreateToyRequest;

  factory CreateToyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateToyRequestFromJson(json);
}

@freezed
class AssignToyRequest with _$AssignToyRequest {
  const AssignToyRequest._();
  
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
  const AssignToyResponse._();
  
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
  const UpdateToyStatusRequest._();
  
  const factory UpdateToyStatusRequest({
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) = _UpdateToyStatusRequest;

  factory UpdateToyStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateToyStatusRequestFromJson(json);
}
