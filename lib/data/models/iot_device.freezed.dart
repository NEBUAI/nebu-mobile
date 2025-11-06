// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IoTDevice {

 String get id; String get name; String get type; DeviceStatus get status; String? get lastSeen; Map<String, dynamic>? get metadata;
/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IoTDeviceCopyWith<IoTDevice> get copyWith => _$IoTDeviceCopyWithImpl<IoTDevice>(this as IoTDevice, _$identity);

  /// Serializes this IoTDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IoTDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,status,lastSeen,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'IoTDevice(id: $id, name: $name, type: $type, status: $status, lastSeen: $lastSeen, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $IoTDeviceCopyWith<$Res>  {
  factory $IoTDeviceCopyWith(IoTDevice value, $Res Function(IoTDevice) _then) = _$IoTDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, DeviceStatus status, String? lastSeen, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$IoTDeviceCopyWithImpl<$Res>
    implements $IoTDeviceCopyWith<$Res> {
  _$IoTDeviceCopyWithImpl(this._self, this._then);

  final IoTDevice _self;
  final $Res Function(IoTDevice) _then;

/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? status = null,Object? lastSeen = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [IoTDevice].
extension IoTDevicePatterns on IoTDevice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IoTDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IoTDevice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IoTDevice value)  $default,){
final _that = this;
switch (_that) {
case _IoTDevice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IoTDevice value)?  $default,){
final _that = this;
switch (_that) {
case _IoTDevice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  DeviceStatus status,  String? lastSeen,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IoTDevice() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.status,_that.lastSeen,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  DeviceStatus status,  String? lastSeen,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _IoTDevice():
return $default(_that.id,_that.name,_that.type,_that.status,_that.lastSeen,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  DeviceStatus status,  String? lastSeen,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _IoTDevice() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.status,_that.lastSeen,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IoTDevice extends IoTDevice {
  const _IoTDevice({required this.id, required this.name, required this.type, required this.status, this.lastSeen, final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _IoTDevice.fromJson(Map<String, dynamic> json) => _$IoTDeviceFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  DeviceStatus status;
@override final  String? lastSeen;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IoTDeviceCopyWith<_IoTDevice> get copyWith => __$IoTDeviceCopyWithImpl<_IoTDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IoTDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IoTDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,status,lastSeen,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'IoTDevice(id: $id, name: $name, type: $type, status: $status, lastSeen: $lastSeen, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$IoTDeviceCopyWith<$Res> implements $IoTDeviceCopyWith<$Res> {
  factory _$IoTDeviceCopyWith(_IoTDevice value, $Res Function(_IoTDevice) _then) = __$IoTDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, DeviceStatus status, String? lastSeen, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$IoTDeviceCopyWithImpl<$Res>
    implements _$IoTDeviceCopyWith<$Res> {
  __$IoTDeviceCopyWithImpl(this._self, this._then);

  final _IoTDevice _self;
  final $Res Function(_IoTDevice) _then;

/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? status = null,Object? lastSeen = freezed,Object? metadata = freezed,}) {
  return _then(_IoTDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$IoTMetrics {

 Map<String, dynamic> get data;
/// Create a copy of IoTMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IoTMetricsCopyWith<IoTMetrics> get copyWith => _$IoTMetricsCopyWithImpl<IoTMetrics>(this as IoTMetrics, _$identity);

  /// Serializes this IoTMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IoTMetrics&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'IoTMetrics(data: $data)';
}


}

/// @nodoc
abstract mixin class $IoTMetricsCopyWith<$Res>  {
  factory $IoTMetricsCopyWith(IoTMetrics value, $Res Function(IoTMetrics) _then) = _$IoTMetricsCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data
});




}
/// @nodoc
class _$IoTMetricsCopyWithImpl<$Res>
    implements $IoTMetricsCopyWith<$Res> {
  _$IoTMetricsCopyWithImpl(this._self, this._then);

  final IoTMetrics _self;
  final $Res Function(IoTMetrics) _then;

/// Create a copy of IoTMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [IoTMetrics].
extension IoTMetricsPatterns on IoTMetrics {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IoTMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IoTMetrics() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IoTMetrics value)  $default,){
final _that = this;
switch (_that) {
case _IoTMetrics():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IoTMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _IoTMetrics() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IoTMetrics() when $default != null:
return $default(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _IoTMetrics():
return $default(_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _IoTMetrics() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IoTMetrics extends IoTMetrics {
  const _IoTMetrics({final  Map<String, dynamic> data = const {}}): _data = data,super._();
  factory _IoTMetrics.fromJson(Map<String, dynamic> json) => _$IoTMetricsFromJson(json);

 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of IoTMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IoTMetricsCopyWith<_IoTMetrics> get copyWith => __$IoTMetricsCopyWithImpl<_IoTMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IoTMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IoTMetrics&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'IoTMetrics(data: $data)';
}


}

/// @nodoc
abstract mixin class _$IoTMetricsCopyWith<$Res> implements $IoTMetricsCopyWith<$Res> {
  factory _$IoTMetricsCopyWith(_IoTMetrics value, $Res Function(_IoTMetrics) _then) = __$IoTMetricsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> data
});




}
/// @nodoc
class __$IoTMetricsCopyWithImpl<$Res>
    implements _$IoTMetricsCopyWith<$Res> {
  __$IoTMetricsCopyWithImpl(this._self, this._then);

  final _IoTMetrics _self;
  final $Res Function(_IoTMetrics) _then;

/// Create a copy of IoTMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_IoTMetrics(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
