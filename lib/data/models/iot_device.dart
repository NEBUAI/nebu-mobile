import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device.freezed.dart';
part 'iot_device.g.dart';

enum DeviceStatus {
  @JsonValue('online')
  online,
  @JsonValue('offline')
  offline,
}

@freezed
class IoTDevice with _$IoTDevice {
  const factory IoTDevice({
    required String id,
    required String name,
    required String type,
    required DeviceStatus status,
    String? lastSeen,
    Map<String, dynamic>? metadata,
  }) = _IoTDevice;

  factory IoTDevice.fromJson(Map<String, dynamic> json) =>
      _$IoTDeviceFromJson(json);
}

@freezed
class IoTMetrics with _$IoTMetrics {
  const factory IoTMetrics({@Default({}) Map<String, dynamic> data}) =
      _IoTMetrics;

  factory IoTMetrics.fromJson(Map<String, dynamic> json) =>
      _$IoTMetricsFromJson(json);
}
