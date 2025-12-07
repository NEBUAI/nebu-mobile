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
mixin _$DeviceModel {

 String get id; String get name; String? get manufacturer; String? get description; String? get imageUrl;
/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceModelCopyWith<DeviceModel> get copyWith => _$DeviceModelCopyWithImpl<DeviceModel>(this as DeviceModel, _$identity);

  /// Serializes this DeviceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,manufacturer,description,imageUrl);

@override
String toString() {
  return 'DeviceModel(id: $id, name: $name, manufacturer: $manufacturer, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $DeviceModelCopyWith<$Res>  {
  factory $DeviceModelCopyWith(DeviceModel value, $Res Function(DeviceModel) _then) = _$DeviceModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? manufacturer, String? description, String? imageUrl
});




}
/// @nodoc
class _$DeviceModelCopyWithImpl<$Res>
    implements $DeviceModelCopyWith<$Res> {
  _$DeviceModelCopyWithImpl(this._self, this._then);

  final DeviceModel _self;
  final $Res Function(DeviceModel) _then;

/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? manufacturer = freezed,Object? description = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceModel].
extension DeviceModelPatterns on DeviceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceModel value)  $default,){
final _that = this;
switch (_that) {
case _DeviceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceModel value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? manufacturer,  String? description,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
return $default(_that.id,_that.name,_that.manufacturer,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? manufacturer,  String? description,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _DeviceModel():
return $default(_that.id,_that.name,_that.manufacturer,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? manufacturer,  String? description,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _DeviceModel() when $default != null:
return $default(_that.id,_that.name,_that.manufacturer,_that.description,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceModel implements DeviceModel {
  const _DeviceModel({required this.id, required this.name, this.manufacturer, this.description, this.imageUrl});
  factory _DeviceModel.fromJson(Map<String, dynamic> json) => _$DeviceModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? manufacturer;
@override final  String? description;
@override final  String? imageUrl;

/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceModelCopyWith<_DeviceModel> get copyWith => __$DeviceModelCopyWithImpl<_DeviceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,manufacturer,description,imageUrl);

@override
String toString() {
  return 'DeviceModel(id: $id, name: $name, manufacturer: $manufacturer, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$DeviceModelCopyWith<$Res> implements $DeviceModelCopyWith<$Res> {
  factory _$DeviceModelCopyWith(_DeviceModel value, $Res Function(_DeviceModel) _then) = __$DeviceModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? manufacturer, String? description, String? imageUrl
});




}
/// @nodoc
class __$DeviceModelCopyWithImpl<$Res>
    implements _$DeviceModelCopyWith<$Res> {
  __$DeviceModelCopyWithImpl(this._self, this._then);

  final _DeviceModel _self;
  final $Res Function(_DeviceModel) _then;

/// Create a copy of DeviceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? manufacturer = freezed,Object? description = freezed,Object? imageUrl = freezed,}) {
  return _then(_DeviceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IoTDevice {

 String get id; String get name; DeviceStatus get status; String? get deviceModelId; DeviceModel? get deviceModel; String? get macAddress; String? get deviceId; String? get ipAddress; DeviceType? get deviceType; String? get locationId; String? get currentFirmwareId; String? get userId; String? get roomName; DateTime? get lastSeen; DateTime? get lastDataReceived; double? get temperature; double? get humidity; int? get batteryLevel; int? get signalStrength; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt; bool get retired;
/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IoTDeviceCopyWith<IoTDevice> get copyWith => _$IoTDeviceCopyWithImpl<IoTDevice>(this as IoTDevice, _$identity);

  /// Serializes this IoTDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IoTDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.deviceModelId, deviceModelId) || other.deviceModelId == deviceModelId)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.currentFirmwareId, currentFirmwareId) || other.currentFirmwareId == currentFirmwareId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.lastDataReceived, lastDataReceived) || other.lastDataReceived == lastDataReceived)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.signalStrength, signalStrength) || other.signalStrength == signalStrength)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.retired, retired) || other.retired == retired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,deviceModelId,deviceModel,macAddress,deviceId,ipAddress,deviceType,locationId,currentFirmwareId,userId,roomName,lastSeen,lastDataReceived,temperature,humidity,batteryLevel,signalStrength,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,retired]);

@override
String toString() {
  return 'IoTDevice(id: $id, name: $name, status: $status, deviceModelId: $deviceModelId, deviceModel: $deviceModel, macAddress: $macAddress, deviceId: $deviceId, ipAddress: $ipAddress, deviceType: $deviceType, locationId: $locationId, currentFirmwareId: $currentFirmwareId, userId: $userId, roomName: $roomName, lastSeen: $lastSeen, lastDataReceived: $lastDataReceived, temperature: $temperature, humidity: $humidity, batteryLevel: $batteryLevel, signalStrength: $signalStrength, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, retired: $retired)';
}


}

/// @nodoc
abstract mixin class $IoTDeviceCopyWith<$Res>  {
  factory $IoTDeviceCopyWith(IoTDevice value, $Res Function(IoTDevice) _then) = _$IoTDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, DeviceStatus status, String? deviceModelId, DeviceModel? deviceModel, String? macAddress, String? deviceId, String? ipAddress, DeviceType? deviceType, String? locationId, String? currentFirmwareId, String? userId, String? roomName, DateTime? lastSeen, DateTime? lastDataReceived, double? temperature, double? humidity, int? batteryLevel, int? signalStrength, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt, bool retired
});


$DeviceModelCopyWith<$Res>? get deviceModel;

}
/// @nodoc
class _$IoTDeviceCopyWithImpl<$Res>
    implements $IoTDeviceCopyWith<$Res> {
  _$IoTDeviceCopyWithImpl(this._self, this._then);

  final IoTDevice _self;
  final $Res Function(IoTDevice) _then;

/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? deviceModelId = freezed,Object? deviceModel = freezed,Object? macAddress = freezed,Object? deviceId = freezed,Object? ipAddress = freezed,Object? deviceType = freezed,Object? locationId = freezed,Object? currentFirmwareId = freezed,Object? userId = freezed,Object? roomName = freezed,Object? lastSeen = freezed,Object? lastDataReceived = freezed,Object? temperature = freezed,Object? humidity = freezed,Object? batteryLevel = freezed,Object? signalStrength = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? retired = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus,deviceModelId: freezed == deviceModelId ? _self.deviceModelId : deviceModelId // ignore: cast_nullable_to_non_nullable
as String?,deviceModel: freezed == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as DeviceModel?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,currentFirmwareId: freezed == currentFirmwareId ? _self.currentFirmwareId : currentFirmwareId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,lastDataReceived: freezed == lastDataReceived ? _self.lastDataReceived : lastDataReceived // ignore: cast_nullable_to_non_nullable
as DateTime?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,signalStrength: freezed == signalStrength ? _self.signalStrength : signalStrength // ignore: cast_nullable_to_non_nullable
as int?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retired: null == retired ? _self.retired : retired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceModelCopyWith<$Res>? get deviceModel {
    if (_self.deviceModel == null) {
    return null;
  }

  return $DeviceModelCopyWith<$Res>(_self.deviceModel!, (value) {
    return _then(_self.copyWith(deviceModel: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DeviceStatus status,  String? deviceModelId,  DeviceModel? deviceModel,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  String? locationId,  String? currentFirmwareId,  String? userId,  String? roomName,  DateTime? lastSeen,  DateTime? lastDataReceived,  double? temperature,  double? humidity,  int? batteryLevel,  int? signalStrength,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  bool retired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IoTDevice() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.deviceModelId,_that.deviceModel,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.locationId,_that.currentFirmwareId,_that.userId,_that.roomName,_that.lastSeen,_that.lastDataReceived,_that.temperature,_that.humidity,_that.batteryLevel,_that.signalStrength,_that.metadata,_that.createdAt,_that.updatedAt,_that.retired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DeviceStatus status,  String? deviceModelId,  DeviceModel? deviceModel,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  String? locationId,  String? currentFirmwareId,  String? userId,  String? roomName,  DateTime? lastSeen,  DateTime? lastDataReceived,  double? temperature,  double? humidity,  int? batteryLevel,  int? signalStrength,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  bool retired)  $default,) {final _that = this;
switch (_that) {
case _IoTDevice():
return $default(_that.id,_that.name,_that.status,_that.deviceModelId,_that.deviceModel,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.locationId,_that.currentFirmwareId,_that.userId,_that.roomName,_that.lastSeen,_that.lastDataReceived,_that.temperature,_that.humidity,_that.batteryLevel,_that.signalStrength,_that.metadata,_that.createdAt,_that.updatedAt,_that.retired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DeviceStatus status,  String? deviceModelId,  DeviceModel? deviceModel,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  String? locationId,  String? currentFirmwareId,  String? userId,  String? roomName,  DateTime? lastSeen,  DateTime? lastDataReceived,  double? temperature,  double? humidity,  int? batteryLevel,  int? signalStrength,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  bool retired)?  $default,) {final _that = this;
switch (_that) {
case _IoTDevice() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.deviceModelId,_that.deviceModel,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.locationId,_that.currentFirmwareId,_that.userId,_that.roomName,_that.lastSeen,_that.lastDataReceived,_that.temperature,_that.humidity,_that.batteryLevel,_that.signalStrength,_that.metadata,_that.createdAt,_that.updatedAt,_that.retired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IoTDevice implements IoTDevice {
  const _IoTDevice({required this.id, required this.name, required this.status, this.deviceModelId, this.deviceModel, this.macAddress, this.deviceId, this.ipAddress, this.deviceType, this.locationId, this.currentFirmwareId, this.userId, this.roomName, this.lastSeen, this.lastDataReceived, this.temperature, this.humidity, this.batteryLevel, this.signalStrength, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt, this.retired = false}): _metadata = metadata;
  factory _IoTDevice.fromJson(Map<String, dynamic> json) => _$IoTDeviceFromJson(json);

@override final  String id;
@override final  String name;
@override final  DeviceStatus status;
@override final  String? deviceModelId;
@override final  DeviceModel? deviceModel;
@override final  String? macAddress;
@override final  String? deviceId;
@override final  String? ipAddress;
@override final  DeviceType? deviceType;
@override final  String? locationId;
@override final  String? currentFirmwareId;
@override final  String? userId;
@override final  String? roomName;
@override final  DateTime? lastSeen;
@override final  DateTime? lastDataReceived;
@override final  double? temperature;
@override final  double? humidity;
@override final  int? batteryLevel;
@override final  int? signalStrength;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool retired;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IoTDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.deviceModelId, deviceModelId) || other.deviceModelId == deviceModelId)&&(identical(other.deviceModel, deviceModel) || other.deviceModel == deviceModel)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.currentFirmwareId, currentFirmwareId) || other.currentFirmwareId == currentFirmwareId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.lastDataReceived, lastDataReceived) || other.lastDataReceived == lastDataReceived)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.signalStrength, signalStrength) || other.signalStrength == signalStrength)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.retired, retired) || other.retired == retired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,deviceModelId,deviceModel,macAddress,deviceId,ipAddress,deviceType,locationId,currentFirmwareId,userId,roomName,lastSeen,lastDataReceived,temperature,humidity,batteryLevel,signalStrength,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,retired]);

@override
String toString() {
  return 'IoTDevice(id: $id, name: $name, status: $status, deviceModelId: $deviceModelId, deviceModel: $deviceModel, macAddress: $macAddress, deviceId: $deviceId, ipAddress: $ipAddress, deviceType: $deviceType, locationId: $locationId, currentFirmwareId: $currentFirmwareId, userId: $userId, roomName: $roomName, lastSeen: $lastSeen, lastDataReceived: $lastDataReceived, temperature: $temperature, humidity: $humidity, batteryLevel: $batteryLevel, signalStrength: $signalStrength, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, retired: $retired)';
}


}

/// @nodoc
abstract mixin class _$IoTDeviceCopyWith<$Res> implements $IoTDeviceCopyWith<$Res> {
  factory _$IoTDeviceCopyWith(_IoTDevice value, $Res Function(_IoTDevice) _then) = __$IoTDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DeviceStatus status, String? deviceModelId, DeviceModel? deviceModel, String? macAddress, String? deviceId, String? ipAddress, DeviceType? deviceType, String? locationId, String? currentFirmwareId, String? userId, String? roomName, DateTime? lastSeen, DateTime? lastDataReceived, double? temperature, double? humidity, int? batteryLevel, int? signalStrength, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt, bool retired
});


@override $DeviceModelCopyWith<$Res>? get deviceModel;

}
/// @nodoc
class __$IoTDeviceCopyWithImpl<$Res>
    implements _$IoTDeviceCopyWith<$Res> {
  __$IoTDeviceCopyWithImpl(this._self, this._then);

  final _IoTDevice _self;
  final $Res Function(_IoTDevice) _then;

/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? deviceModelId = freezed,Object? deviceModel = freezed,Object? macAddress = freezed,Object? deviceId = freezed,Object? ipAddress = freezed,Object? deviceType = freezed,Object? locationId = freezed,Object? currentFirmwareId = freezed,Object? userId = freezed,Object? roomName = freezed,Object? lastSeen = freezed,Object? lastDataReceived = freezed,Object? temperature = freezed,Object? humidity = freezed,Object? batteryLevel = freezed,Object? signalStrength = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? retired = null,}) {
  return _then(_IoTDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus,deviceModelId: freezed == deviceModelId ? _self.deviceModelId : deviceModelId // ignore: cast_nullable_to_non_nullable
as String?,deviceModel: freezed == deviceModel ? _self.deviceModel : deviceModel // ignore: cast_nullable_to_non_nullable
as DeviceModel?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,currentFirmwareId: freezed == currentFirmwareId ? _self.currentFirmwareId : currentFirmwareId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,lastDataReceived: freezed == lastDataReceived ? _self.lastDataReceived : lastDataReceived // ignore: cast_nullable_to_non_nullable
as DateTime?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,signalStrength: freezed == signalStrength ? _self.signalStrength : signalStrength // ignore: cast_nullable_to_non_nullable
as int?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retired: null == retired ? _self.retired : retired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of IoTDevice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceModelCopyWith<$Res>? get deviceModel {
    if (_self.deviceModel == null) {
    return null;
  }

  return $DeviceModelCopyWith<$Res>(_self.deviceModel!, (value) {
    return _then(_self.copyWith(deviceModel: value));
  });
}
}


/// @nodoc
mixin _$IoTMetrics {

 int get totalDevices; int get onlineDevices; int get offlineDevices; int get errorDevices; Map<String, int> get devicesByType; Map<String, dynamic> get data;
/// Create a copy of IoTMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IoTMetricsCopyWith<IoTMetrics> get copyWith => _$IoTMetricsCopyWithImpl<IoTMetrics>(this as IoTMetrics, _$identity);

  /// Serializes this IoTMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IoTMetrics&&(identical(other.totalDevices, totalDevices) || other.totalDevices == totalDevices)&&(identical(other.onlineDevices, onlineDevices) || other.onlineDevices == onlineDevices)&&(identical(other.offlineDevices, offlineDevices) || other.offlineDevices == offlineDevices)&&(identical(other.errorDevices, errorDevices) || other.errorDevices == errorDevices)&&const DeepCollectionEquality().equals(other.devicesByType, devicesByType)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDevices,onlineDevices,offlineDevices,errorDevices,const DeepCollectionEquality().hash(devicesByType),const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'IoTMetrics(totalDevices: $totalDevices, onlineDevices: $onlineDevices, offlineDevices: $offlineDevices, errorDevices: $errorDevices, devicesByType: $devicesByType, data: $data)';
}


}

/// @nodoc
abstract mixin class $IoTMetricsCopyWith<$Res>  {
  factory $IoTMetricsCopyWith(IoTMetrics value, $Res Function(IoTMetrics) _then) = _$IoTMetricsCopyWithImpl;
@useResult
$Res call({
 int totalDevices, int onlineDevices, int offlineDevices, int errorDevices, Map<String, int> devicesByType, Map<String, dynamic> data
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
@pragma('vm:prefer-inline') @override $Res call({Object? totalDevices = null,Object? onlineDevices = null,Object? offlineDevices = null,Object? errorDevices = null,Object? devicesByType = null,Object? data = null,}) {
  return _then(_self.copyWith(
totalDevices: null == totalDevices ? _self.totalDevices : totalDevices // ignore: cast_nullable_to_non_nullable
as int,onlineDevices: null == onlineDevices ? _self.onlineDevices : onlineDevices // ignore: cast_nullable_to_non_nullable
as int,offlineDevices: null == offlineDevices ? _self.offlineDevices : offlineDevices // ignore: cast_nullable_to_non_nullable
as int,errorDevices: null == errorDevices ? _self.errorDevices : errorDevices // ignore: cast_nullable_to_non_nullable
as int,devicesByType: null == devicesByType ? _self.devicesByType : devicesByType // ignore: cast_nullable_to_non_nullable
as Map<String, int>,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalDevices,  int onlineDevices,  int offlineDevices,  int errorDevices,  Map<String, int> devicesByType,  Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IoTMetrics() when $default != null:
return $default(_that.totalDevices,_that.onlineDevices,_that.offlineDevices,_that.errorDevices,_that.devicesByType,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalDevices,  int onlineDevices,  int offlineDevices,  int errorDevices,  Map<String, int> devicesByType,  Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _IoTMetrics():
return $default(_that.totalDevices,_that.onlineDevices,_that.offlineDevices,_that.errorDevices,_that.devicesByType,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalDevices,  int onlineDevices,  int offlineDevices,  int errorDevices,  Map<String, int> devicesByType,  Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _IoTMetrics() when $default != null:
return $default(_that.totalDevices,_that.onlineDevices,_that.offlineDevices,_that.errorDevices,_that.devicesByType,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IoTMetrics implements IoTMetrics {
  const _IoTMetrics({this.totalDevices = 0, this.onlineDevices = 0, this.offlineDevices = 0, this.errorDevices = 0, final  Map<String, int> devicesByType = const {}, final  Map<String, dynamic> data = const {}}): _devicesByType = devicesByType,_data = data;
  factory _IoTMetrics.fromJson(Map<String, dynamic> json) => _$IoTMetricsFromJson(json);

@override@JsonKey() final  int totalDevices;
@override@JsonKey() final  int onlineDevices;
@override@JsonKey() final  int offlineDevices;
@override@JsonKey() final  int errorDevices;
 final  Map<String, int> _devicesByType;
@override@JsonKey() Map<String, int> get devicesByType {
  if (_devicesByType is EqualUnmodifiableMapView) return _devicesByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_devicesByType);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IoTMetrics&&(identical(other.totalDevices, totalDevices) || other.totalDevices == totalDevices)&&(identical(other.onlineDevices, onlineDevices) || other.onlineDevices == onlineDevices)&&(identical(other.offlineDevices, offlineDevices) || other.offlineDevices == offlineDevices)&&(identical(other.errorDevices, errorDevices) || other.errorDevices == errorDevices)&&const DeepCollectionEquality().equals(other._devicesByType, _devicesByType)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDevices,onlineDevices,offlineDevices,errorDevices,const DeepCollectionEquality().hash(_devicesByType),const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'IoTMetrics(totalDevices: $totalDevices, onlineDevices: $onlineDevices, offlineDevices: $offlineDevices, errorDevices: $errorDevices, devicesByType: $devicesByType, data: $data)';
}


}

/// @nodoc
abstract mixin class _$IoTMetricsCopyWith<$Res> implements $IoTMetricsCopyWith<$Res> {
  factory _$IoTMetricsCopyWith(_IoTMetrics value, $Res Function(_IoTMetrics) _then) = __$IoTMetricsCopyWithImpl;
@override @useResult
$Res call({
 int totalDevices, int onlineDevices, int offlineDevices, int errorDevices, Map<String, int> devicesByType, Map<String, dynamic> data
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
@override @pragma('vm:prefer-inline') $Res call({Object? totalDevices = null,Object? onlineDevices = null,Object? offlineDevices = null,Object? errorDevices = null,Object? devicesByType = null,Object? data = null,}) {
  return _then(_IoTMetrics(
totalDevices: null == totalDevices ? _self.totalDevices : totalDevices // ignore: cast_nullable_to_non_nullable
as int,onlineDevices: null == onlineDevices ? _self.onlineDevices : onlineDevices // ignore: cast_nullable_to_non_nullable
as int,offlineDevices: null == offlineDevices ? _self.offlineDevices : offlineDevices // ignore: cast_nullable_to_non_nullable
as int,errorDevices: null == errorDevices ? _self.errorDevices : errorDevices // ignore: cast_nullable_to_non_nullable
as int,devicesByType: null == devicesByType ? _self._devicesByType : devicesByType // ignore: cast_nullable_to_non_nullable
as Map<String, int>,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$CreateIoTDeviceDto {

 String get name; String? get deviceModelId; String? get macAddress; String? get deviceId; String? get ipAddress; DeviceType? get deviceType; String? get locationId; String? get userId; Map<String, dynamic>? get metadata;
/// Create a copy of CreateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateIoTDeviceDtoCopyWith<CreateIoTDeviceDto> get copyWith => _$CreateIoTDeviceDtoCopyWithImpl<CreateIoTDeviceDto>(this as CreateIoTDeviceDto, _$identity);

  /// Serializes this CreateIoTDeviceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateIoTDeviceDto&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceModelId, deviceModelId) || other.deviceModelId == deviceModelId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,deviceModelId,macAddress,deviceId,ipAddress,deviceType,locationId,userId,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'CreateIoTDeviceDto(name: $name, deviceModelId: $deviceModelId, macAddress: $macAddress, deviceId: $deviceId, ipAddress: $ipAddress, deviceType: $deviceType, locationId: $locationId, userId: $userId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CreateIoTDeviceDtoCopyWith<$Res>  {
  factory $CreateIoTDeviceDtoCopyWith(CreateIoTDeviceDto value, $Res Function(CreateIoTDeviceDto) _then) = _$CreateIoTDeviceDtoCopyWithImpl;
@useResult
$Res call({
 String name, String? deviceModelId, String? macAddress, String? deviceId, String? ipAddress, DeviceType? deviceType, String? locationId, String? userId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$CreateIoTDeviceDtoCopyWithImpl<$Res>
    implements $CreateIoTDeviceDtoCopyWith<$Res> {
  _$CreateIoTDeviceDtoCopyWithImpl(this._self, this._then);

  final CreateIoTDeviceDto _self;
  final $Res Function(CreateIoTDeviceDto) _then;

/// Create a copy of CreateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? deviceModelId = freezed,Object? macAddress = freezed,Object? deviceId = freezed,Object? ipAddress = freezed,Object? deviceType = freezed,Object? locationId = freezed,Object? userId = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deviceModelId: freezed == deviceModelId ? _self.deviceModelId : deviceModelId // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateIoTDeviceDto].
extension CreateIoTDeviceDtoPatterns on CreateIoTDeviceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateIoTDeviceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateIoTDeviceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateIoTDeviceDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateIoTDeviceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateIoTDeviceDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateIoTDeviceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? deviceModelId,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  String? locationId,  String? userId,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateIoTDeviceDto() when $default != null:
return $default(_that.name,_that.deviceModelId,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.locationId,_that.userId,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? deviceModelId,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  String? locationId,  String? userId,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _CreateIoTDeviceDto():
return $default(_that.name,_that.deviceModelId,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.locationId,_that.userId,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? deviceModelId,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  String? locationId,  String? userId,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _CreateIoTDeviceDto() when $default != null:
return $default(_that.name,_that.deviceModelId,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.locationId,_that.userId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateIoTDeviceDto implements CreateIoTDeviceDto {
  const _CreateIoTDeviceDto({required this.name, this.deviceModelId, this.macAddress, this.deviceId, this.ipAddress, this.deviceType, this.locationId, this.userId, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _CreateIoTDeviceDto.fromJson(Map<String, dynamic> json) => _$CreateIoTDeviceDtoFromJson(json);

@override final  String name;
@override final  String? deviceModelId;
@override final  String? macAddress;
@override final  String? deviceId;
@override final  String? ipAddress;
@override final  DeviceType? deviceType;
@override final  String? locationId;
@override final  String? userId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CreateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateIoTDeviceDtoCopyWith<_CreateIoTDeviceDto> get copyWith => __$CreateIoTDeviceDtoCopyWithImpl<_CreateIoTDeviceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateIoTDeviceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateIoTDeviceDto&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceModelId, deviceModelId) || other.deviceModelId == deviceModelId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,deviceModelId,macAddress,deviceId,ipAddress,deviceType,locationId,userId,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'CreateIoTDeviceDto(name: $name, deviceModelId: $deviceModelId, macAddress: $macAddress, deviceId: $deviceId, ipAddress: $ipAddress, deviceType: $deviceType, locationId: $locationId, userId: $userId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CreateIoTDeviceDtoCopyWith<$Res> implements $CreateIoTDeviceDtoCopyWith<$Res> {
  factory _$CreateIoTDeviceDtoCopyWith(_CreateIoTDeviceDto value, $Res Function(_CreateIoTDeviceDto) _then) = __$CreateIoTDeviceDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String? deviceModelId, String? macAddress, String? deviceId, String? ipAddress, DeviceType? deviceType, String? locationId, String? userId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$CreateIoTDeviceDtoCopyWithImpl<$Res>
    implements _$CreateIoTDeviceDtoCopyWith<$Res> {
  __$CreateIoTDeviceDtoCopyWithImpl(this._self, this._then);

  final _CreateIoTDeviceDto _self;
  final $Res Function(_CreateIoTDeviceDto) _then;

/// Create a copy of CreateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? deviceModelId = freezed,Object? macAddress = freezed,Object? deviceId = freezed,Object? ipAddress = freezed,Object? deviceType = freezed,Object? locationId = freezed,Object? userId = freezed,Object? metadata = freezed,}) {
  return _then(_CreateIoTDeviceDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deviceModelId: freezed == deviceModelId ? _self.deviceModelId : deviceModelId // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$UpdateIoTDeviceDto {

 String? get name; String? get deviceModelId; String? get macAddress; String? get deviceId; String? get ipAddress; DeviceType? get deviceType; DeviceStatus? get status; String? get locationId; String? get roomName; Map<String, dynamic>? get metadata;
/// Create a copy of UpdateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateIoTDeviceDtoCopyWith<UpdateIoTDeviceDto> get copyWith => _$UpdateIoTDeviceDtoCopyWithImpl<UpdateIoTDeviceDto>(this as UpdateIoTDeviceDto, _$identity);

  /// Serializes this UpdateIoTDeviceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateIoTDeviceDto&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceModelId, deviceModelId) || other.deviceModelId == deviceModelId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.status, status) || other.status == status)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,deviceModelId,macAddress,deviceId,ipAddress,deviceType,status,locationId,roomName,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'UpdateIoTDeviceDto(name: $name, deviceModelId: $deviceModelId, macAddress: $macAddress, deviceId: $deviceId, ipAddress: $ipAddress, deviceType: $deviceType, status: $status, locationId: $locationId, roomName: $roomName, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $UpdateIoTDeviceDtoCopyWith<$Res>  {
  factory $UpdateIoTDeviceDtoCopyWith(UpdateIoTDeviceDto value, $Res Function(UpdateIoTDeviceDto) _then) = _$UpdateIoTDeviceDtoCopyWithImpl;
@useResult
$Res call({
 String? name, String? deviceModelId, String? macAddress, String? deviceId, String? ipAddress, DeviceType? deviceType, DeviceStatus? status, String? locationId, String? roomName, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$UpdateIoTDeviceDtoCopyWithImpl<$Res>
    implements $UpdateIoTDeviceDtoCopyWith<$Res> {
  _$UpdateIoTDeviceDtoCopyWithImpl(this._self, this._then);

  final UpdateIoTDeviceDto _self;
  final $Res Function(UpdateIoTDeviceDto) _then;

/// Create a copy of UpdateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? deviceModelId = freezed,Object? macAddress = freezed,Object? deviceId = freezed,Object? ipAddress = freezed,Object? deviceType = freezed,Object? status = freezed,Object? locationId = freezed,Object? roomName = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,deviceModelId: freezed == deviceModelId ? _self.deviceModelId : deviceModelId // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateIoTDeviceDto].
extension UpdateIoTDeviceDtoPatterns on UpdateIoTDeviceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateIoTDeviceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateIoTDeviceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateIoTDeviceDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateIoTDeviceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateIoTDeviceDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateIoTDeviceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? deviceModelId,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  DeviceStatus? status,  String? locationId,  String? roomName,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateIoTDeviceDto() when $default != null:
return $default(_that.name,_that.deviceModelId,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.status,_that.locationId,_that.roomName,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? deviceModelId,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  DeviceStatus? status,  String? locationId,  String? roomName,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _UpdateIoTDeviceDto():
return $default(_that.name,_that.deviceModelId,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.status,_that.locationId,_that.roomName,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? deviceModelId,  String? macAddress,  String? deviceId,  String? ipAddress,  DeviceType? deviceType,  DeviceStatus? status,  String? locationId,  String? roomName,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _UpdateIoTDeviceDto() when $default != null:
return $default(_that.name,_that.deviceModelId,_that.macAddress,_that.deviceId,_that.ipAddress,_that.deviceType,_that.status,_that.locationId,_that.roomName,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateIoTDeviceDto implements UpdateIoTDeviceDto {
  const _UpdateIoTDeviceDto({this.name, this.deviceModelId, this.macAddress, this.deviceId, this.ipAddress, this.deviceType, this.status, this.locationId, this.roomName, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _UpdateIoTDeviceDto.fromJson(Map<String, dynamic> json) => _$UpdateIoTDeviceDtoFromJson(json);

@override final  String? name;
@override final  String? deviceModelId;
@override final  String? macAddress;
@override final  String? deviceId;
@override final  String? ipAddress;
@override final  DeviceType? deviceType;
@override final  DeviceStatus? status;
@override final  String? locationId;
@override final  String? roomName;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UpdateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateIoTDeviceDtoCopyWith<_UpdateIoTDeviceDto> get copyWith => __$UpdateIoTDeviceDtoCopyWithImpl<_UpdateIoTDeviceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateIoTDeviceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateIoTDeviceDto&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceModelId, deviceModelId) || other.deviceModelId == deviceModelId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.status, status) || other.status == status)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,deviceModelId,macAddress,deviceId,ipAddress,deviceType,status,locationId,roomName,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'UpdateIoTDeviceDto(name: $name, deviceModelId: $deviceModelId, macAddress: $macAddress, deviceId: $deviceId, ipAddress: $ipAddress, deviceType: $deviceType, status: $status, locationId: $locationId, roomName: $roomName, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$UpdateIoTDeviceDtoCopyWith<$Res> implements $UpdateIoTDeviceDtoCopyWith<$Res> {
  factory _$UpdateIoTDeviceDtoCopyWith(_UpdateIoTDeviceDto value, $Res Function(_UpdateIoTDeviceDto) _then) = __$UpdateIoTDeviceDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? deviceModelId, String? macAddress, String? deviceId, String? ipAddress, DeviceType? deviceType, DeviceStatus? status, String? locationId, String? roomName, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$UpdateIoTDeviceDtoCopyWithImpl<$Res>
    implements _$UpdateIoTDeviceDtoCopyWith<$Res> {
  __$UpdateIoTDeviceDtoCopyWithImpl(this._self, this._then);

  final _UpdateIoTDeviceDto _self;
  final $Res Function(_UpdateIoTDeviceDto) _then;

/// Create a copy of UpdateIoTDeviceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? deviceModelId = freezed,Object? macAddress = freezed,Object? deviceId = freezed,Object? ipAddress = freezed,Object? deviceType = freezed,Object? status = freezed,Object? locationId = freezed,Object? roomName = freezed,Object? metadata = freezed,}) {
  return _then(_UpdateIoTDeviceDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,deviceModelId: freezed == deviceModelId ? _self.deviceModelId : deviceModelId // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as DeviceType?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
