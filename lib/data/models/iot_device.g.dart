// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IoTDeviceImpl _$$IoTDeviceImplFromJson(Map<String, dynamic> json) =>
    _$IoTDeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: $enumDecode(_$DeviceStatusEnumMap, json['status']),
      lastSeen: json['lastSeen'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$IoTDeviceImplToJson(_$IoTDeviceImpl instance) =>
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

_$IoTMetricsImpl _$$IoTMetricsImplFromJson(Map<String, dynamic> json) =>
    _$IoTMetricsImpl(
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$IoTMetricsImplToJson(_$IoTMetricsImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
