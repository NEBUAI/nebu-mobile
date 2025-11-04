// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IoTDevice _$IoTDeviceFromJson(Map<String, dynamic> json) => _IoTDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: $enumDecode(_$DeviceStatusEnumMap, json['status']),
      lastSeen: json['lastSeen'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$IoTDeviceToJson(_IoTDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'status': _$DeviceStatusEnumMap[instance.status]!,
      'lastSeen': instance.lastSeen,
      'metadata': instance.metadata,
    };

const _$DeviceStatusEnumMap = {
  DeviceStatus.online: 'online',
  DeviceStatus.offline: 'offline',
};

_IoTMetrics _$IoTMetricsFromJson(Map<String, dynamic> json) => _IoTMetrics(
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$IoTMetricsToJson(_IoTMetrics instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
