// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) => _DeviceModel(
  id: json['id'] as String,
  name: json['name'] as String,
  manufacturer: json['manufacturer'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$DeviceModelToJson(_DeviceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'manufacturer': instance.manufacturer,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
    };

_IoTDevice _$IoTDeviceFromJson(Map<String, dynamic> json) => _IoTDevice(
  id: json['id'] as String,
  name: json['name'] as String,
  status: $enumDecode(_$DeviceStatusEnumMap, json['status']),
  deviceModelId: json['deviceModelId'] as String?,
  deviceModel: json['deviceModel'] == null
      ? null
      : DeviceModel.fromJson(json['deviceModel'] as Map<String, dynamic>),
  macAddress: json['macAddress'] as String?,
  deviceId: json['deviceId'] as String?,
  ipAddress: json['ipAddress'] as String?,
  deviceType: $enumDecodeNullable(_$DeviceTypeEnumMap, json['deviceType']),
  locationId: json['locationId'] as String?,
  currentFirmwareId: json['currentFirmwareId'] as String?,
  userId: json['userId'] as String?,
  roomName: json['roomName'] as String?,
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
  lastDataReceived: json['lastDataReceived'] == null
      ? null
      : DateTime.parse(json['lastDataReceived'] as String),
  temperature: (json['temperature'] as num?)?.toDouble(),
  humidity: (json['humidity'] as num?)?.toDouble(),
  batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
  signalStrength: (json['signalStrength'] as num?)?.toInt(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  retired: json['retired'] as bool? ?? false,
);

Map<String, dynamic> _$IoTDeviceToJson(_IoTDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$DeviceStatusEnumMap[instance.status]!,
      'deviceModelId': instance.deviceModelId,
      'deviceModel': instance.deviceModel,
      'macAddress': instance.macAddress,
      'deviceId': instance.deviceId,
      'ipAddress': instance.ipAddress,
      'deviceType': _$DeviceTypeEnumMap[instance.deviceType],
      'locationId': instance.locationId,
      'currentFirmwareId': instance.currentFirmwareId,
      'userId': instance.userId,
      'roomName': instance.roomName,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'lastDataReceived': instance.lastDataReceived?.toIso8601String(),
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'batteryLevel': instance.batteryLevel,
      'signalStrength': instance.signalStrength,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'retired': instance.retired,
    };

const _$DeviceStatusEnumMap = {
  DeviceStatus.online: 'online',
  DeviceStatus.offline: 'offline',
  DeviceStatus.error: 'error',
  DeviceStatus.maintenance: 'maintenance',
};

const _$DeviceTypeEnumMap = {
  DeviceType.sensor: 'sensor',
  DeviceType.actuator: 'actuator',
  DeviceType.camera: 'camera',
  DeviceType.microphone: 'microphone',
  DeviceType.speaker: 'speaker',
  DeviceType.controller: 'controller',
};

_IoTMetrics _$IoTMetricsFromJson(Map<String, dynamic> json) => _IoTMetrics(
  totalDevices: (json['totalDevices'] as num?)?.toInt() ?? 0,
  onlineDevices: (json['onlineDevices'] as num?)?.toInt() ?? 0,
  offlineDevices: (json['offlineDevices'] as num?)?.toInt() ?? 0,
  errorDevices: (json['errorDevices'] as num?)?.toInt() ?? 0,
  devicesByType:
      (json['devicesByType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  data: json['data'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$IoTMetricsToJson(_IoTMetrics instance) =>
    <String, dynamic>{
      'totalDevices': instance.totalDevices,
      'onlineDevices': instance.onlineDevices,
      'offlineDevices': instance.offlineDevices,
      'errorDevices': instance.errorDevices,
      'devicesByType': instance.devicesByType,
      'data': instance.data,
    };

_CreateIoTDeviceDto _$CreateIoTDeviceDtoFromJson(Map<String, dynamic> json) =>
    _CreateIoTDeviceDto(
      name: json['name'] as String,
      deviceModelId: json['deviceModelId'] as String?,
      macAddress: json['macAddress'] as String?,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      deviceType: $enumDecodeNullable(_$DeviceTypeEnumMap, json['deviceType']),
      locationId: json['locationId'] as String?,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateIoTDeviceDtoToJson(_CreateIoTDeviceDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'deviceModelId': instance.deviceModelId,
      'macAddress': instance.macAddress,
      'deviceId': instance.deviceId,
      'ipAddress': instance.ipAddress,
      'deviceType': _$DeviceTypeEnumMap[instance.deviceType],
      'locationId': instance.locationId,
      'userId': instance.userId,
      'metadata': instance.metadata,
    };

_UpdateIoTDeviceDto _$UpdateIoTDeviceDtoFromJson(Map<String, dynamic> json) =>
    _UpdateIoTDeviceDto(
      name: json['name'] as String?,
      deviceModelId: json['deviceModelId'] as String?,
      macAddress: json['macAddress'] as String?,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      deviceType: $enumDecodeNullable(_$DeviceTypeEnumMap, json['deviceType']),
      status: $enumDecodeNullable(_$DeviceStatusEnumMap, json['status']),
      locationId: json['locationId'] as String?,
      roomName: json['roomName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateIoTDeviceDtoToJson(_UpdateIoTDeviceDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'deviceModelId': instance.deviceModelId,
      'macAddress': instance.macAddress,
      'deviceId': instance.deviceId,
      'ipAddress': instance.ipAddress,
      'deviceType': _$DeviceTypeEnumMap[instance.deviceType],
      'status': _$DeviceStatusEnumMap[instance.status],
      'locationId': instance.locationId,
      'roomName': instance.roomName,
      'metadata': instance.metadata,
    };
