// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IoTDevice _$IoTDeviceFromJson(Map<String, dynamic> json) {
  return _IoTDevice.fromJson(json);
}

/// @nodoc
mixin _$IoTDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DeviceStatus get status => throw _privateConstructorUsedError;
  String? get lastSeen => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this IoTDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IoTDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IoTDeviceCopyWith<IoTDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IoTDeviceCopyWith<$Res> {
  factory $IoTDeviceCopyWith(IoTDevice value, $Res Function(IoTDevice) then) =
      _$IoTDeviceCopyWithImpl<$Res, IoTDevice>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      DeviceStatus status,
      String? lastSeen,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$IoTDeviceCopyWithImpl<$Res, $Val extends IoTDevice>
    implements $IoTDeviceCopyWith<$Res> {
  _$IoTDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IoTDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeviceStatus,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IoTDeviceImplCopyWith<$Res>
    implements $IoTDeviceCopyWith<$Res> {
  factory _$$IoTDeviceImplCopyWith(
          _$IoTDeviceImpl value, $Res Function(_$IoTDeviceImpl) then) =
      __$$IoTDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      DeviceStatus status,
      String? lastSeen,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$IoTDeviceImplCopyWithImpl<$Res>
    extends _$IoTDeviceCopyWithImpl<$Res, _$IoTDeviceImpl>
    implements _$$IoTDeviceImplCopyWith<$Res> {
  __$$IoTDeviceImplCopyWithImpl(
      _$IoTDeviceImpl _value, $Res Function(_$IoTDeviceImpl) _then)
      : super(_value, _then);

  /// Create a copy of IoTDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? lastSeen = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$IoTDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeviceStatus,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IoTDeviceImpl implements _IoTDevice {
  const _$IoTDeviceImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      this.lastSeen,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$IoTDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$IoTDeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final DeviceStatus status;
  @override
  final String? lastSeen;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'IoTDevice(id: $id, name: $name, type: $type, status: $status, lastSeen: $lastSeen, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IoTDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, status, lastSeen,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of IoTDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IoTDeviceImplCopyWith<_$IoTDeviceImpl> get copyWith =>
      __$$IoTDeviceImplCopyWithImpl<_$IoTDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IoTDeviceImplToJson(
      this,
    );
  }
}

abstract class _IoTDevice implements IoTDevice {
  const factory _IoTDevice(
      {required final String id,
      required final String name,
      required final String type,
      required final DeviceStatus status,
      final String? lastSeen,
      final Map<String, dynamic>? metadata}) = _$IoTDeviceImpl;

  factory _IoTDevice.fromJson(Map<String, dynamic> json) =
      _$IoTDeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  DeviceStatus get status;
  @override
  String? get lastSeen;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of IoTDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IoTDeviceImplCopyWith<_$IoTDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IoTMetrics _$IoTMetricsFromJson(Map<String, dynamic> json) {
  return _IoTMetrics.fromJson(json);
}

/// @nodoc
mixin _$IoTMetrics {
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// Serializes this IoTMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IoTMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IoTMetricsCopyWith<IoTMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IoTMetricsCopyWith<$Res> {
  factory $IoTMetricsCopyWith(
          IoTMetrics value, $Res Function(IoTMetrics) then) =
      _$IoTMetricsCopyWithImpl<$Res, IoTMetrics>;
  @useResult
  $Res call({Map<String, dynamic> data});
}

/// @nodoc
class _$IoTMetricsCopyWithImpl<$Res, $Val extends IoTMetrics>
    implements $IoTMetricsCopyWith<$Res> {
  _$IoTMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IoTMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IoTMetricsImplCopyWith<$Res>
    implements $IoTMetricsCopyWith<$Res> {
  factory _$$IoTMetricsImplCopyWith(
          _$IoTMetricsImpl value, $Res Function(_$IoTMetricsImpl) then) =
      __$$IoTMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, dynamic> data});
}

/// @nodoc
class __$$IoTMetricsImplCopyWithImpl<$Res>
    extends _$IoTMetricsCopyWithImpl<$Res, _$IoTMetricsImpl>
    implements _$$IoTMetricsImplCopyWith<$Res> {
  __$$IoTMetricsImplCopyWithImpl(
      _$IoTMetricsImpl _value, $Res Function(_$IoTMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of IoTMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$IoTMetricsImpl(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IoTMetricsImpl implements _IoTMetrics {
  const _$IoTMetricsImpl({final Map<String, dynamic> data = const {}})
      : _data = data;

  factory _$IoTMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$IoTMetricsImplFromJson(json);

  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  String toString() {
    return 'IoTMetrics(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IoTMetricsImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of IoTMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IoTMetricsImplCopyWith<_$IoTMetricsImpl> get copyWith =>
      __$$IoTMetricsImplCopyWithImpl<_$IoTMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IoTMetricsImplToJson(
      this,
    );
  }
}

abstract class _IoTMetrics implements IoTMetrics {
  const factory _IoTMetrics({final Map<String, dynamic> data}) =
      _$IoTMetricsImpl;

  factory _IoTMetrics.fromJson(Map<String, dynamic> json) =
      _$IoTMetricsImpl.fromJson;

  @override
  Map<String, dynamic> get data;

  /// Create a copy of IoTMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IoTMetricsImplCopyWith<_$IoTMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
