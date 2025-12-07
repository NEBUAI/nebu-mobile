import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device.freezed.dart';
part 'iot_device.g.dart';

enum DeviceStatus {
  @JsonValue('online')
  online,
  @JsonValue('offline')
  offline,
  @JsonValue('error')
  error,
  @JsonValue('maintenance')
  maintenance,
}

enum DeviceType {
  @JsonValue('sensor')
  sensor,
  @JsonValue('actuator')
  actuator,
  @JsonValue('camera')
  camera,
  @JsonValue('microphone')
  microphone,
  @JsonValue('speaker')
  speaker,
  @JsonValue('controller')
  controller,
}

@freezed
abstract class DeviceModel with _$DeviceModel {
  const factory DeviceModel({
    required String id,
    required String name,
    String? manufacturer,
    String? description,
    String? imageUrl,
  }) = _DeviceModel;

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);
}

@freezed
abstract class IoTDevice with _$IoTDevice {
  const factory IoTDevice({
    required String id,
    required String name,
    required DeviceStatus status,
    String? deviceModelId,
    DeviceModel? deviceModel,
    String? macAddress,
    String? deviceId,
    String? ipAddress,
    DeviceType? deviceType,
    String? locationId,
    String? currentFirmwareId,
    String? userId,
    String? roomName,
    DateTime? lastSeen,
    DateTime? lastDataReceived,
    double? temperature,
    double? humidity,
    int? batteryLevel,
    int? signalStrength,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool retired,
  }) = _IoTDevice;

  factory IoTDevice.fromJson(Map<String, dynamic> json) =>
      _$IoTDeviceFromJson(json);
}

@freezed
abstract class IoTMetrics with _$IoTMetrics {
  const factory IoTMetrics({
    @Default(0) int totalDevices,
    @Default(0) int onlineDevices,
    @Default(0) int offlineDevices,
    @Default(0) int errorDevices,
    @Default({}) Map<String, int> devicesByType,
    @Default({}) Map<String, dynamic> data,
  }) = _IoTMetrics;

  factory IoTMetrics.fromJson(Map<String, dynamic> json) =>
      _$IoTMetricsFromJson(json);
}

@freezed
abstract class CreateIoTDeviceDto with _$CreateIoTDeviceDto {
  const factory CreateIoTDeviceDto({
    required String name,
    String? deviceModelId,
    String? macAddress,
    String? deviceId,
    String? ipAddress,
    DeviceType? deviceType,
    String? locationId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) = _CreateIoTDeviceDto;

  factory CreateIoTDeviceDto.fromJson(Map<String, dynamic> json) =>
      _$CreateIoTDeviceDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    if (deviceModelId != null) 'deviceModelId': deviceModelId,
    if (macAddress != null) 'macAddress': macAddress,
    if (deviceId != null) 'deviceId': deviceId,
    if (ipAddress != null) 'ipAddress': ipAddress,
    if (deviceType != null) 'deviceType': deviceType?.name,
    if (locationId != null) 'locationId': locationId,
    if (userId != null) 'userId': userId,
    if (metadata != null) 'metadata': metadata,
  };
}

@freezed
abstract class UpdateIoTDeviceDto with _$UpdateIoTDeviceDto {
  const factory UpdateIoTDeviceDto({
    String? name,
    String? deviceModelId,
    String? macAddress,
    String? deviceId,
    String? ipAddress,
    DeviceType? deviceType,
    DeviceStatus? status,
    String? locationId,
    String? roomName,
    Map<String, dynamic>? metadata,
  }) = _UpdateIoTDeviceDto;

  factory UpdateIoTDeviceDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateIoTDeviceDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (deviceModelId != null) 'deviceModelId': deviceModelId,
    if (macAddress != null) 'macAddress': macAddress,
    if (deviceId != null) 'deviceId': deviceId,
    if (ipAddress != null) 'ipAddress': ipAddress,
    if (deviceType != null) 'deviceType': deviceType?.name,
    if (status != null) 'status': status?.name,
    if (locationId != null) 'locationId': locationId,
    if (roomName != null) 'roomName': roomName,
    if (metadata != null) 'metadata': metadata,
  };
}
