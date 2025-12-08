// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Activity {

 String get id; String get userId; ActivityType get type; String get description; DateTime get timestamp; DateTime get createdAt; String? get toyId; Map<String, dynamic>? get metadata;
/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityCopyWith<Activity> get copyWith => _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,description,timestamp,createdAt,toyId,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'Activity(id: $id, userId: $userId, type: $type, description: $description, timestamp: $timestamp, createdAt: $createdAt, toyId: $toyId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res>  {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) = _$ActivityCopyWithImpl;
@useResult
$Res call({
 String id, String userId, ActivityType type, String description, DateTime timestamp, DateTime createdAt, String? toyId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ActivityCopyWithImpl<$Res>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? description = null,Object? timestamp = null,Object? createdAt = null,Object? toyId = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Activity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Activity value)  $default,){
final _that = this;
switch (_that) {
case _Activity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Activity value)?  $default,){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  ActivityType type,  String description,  DateTime timestamp,  DateTime createdAt,  String? toyId,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.description,_that.timestamp,_that.createdAt,_that.toyId,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  ActivityType type,  String description,  DateTime timestamp,  DateTime createdAt,  String? toyId,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _Activity():
return $default(_that.id,_that.userId,_that.type,_that.description,_that.timestamp,_that.createdAt,_that.toyId,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  ActivityType type,  String description,  DateTime timestamp,  DateTime createdAt,  String? toyId,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.description,_that.timestamp,_that.createdAt,_that.toyId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Activity implements Activity {
  const _Activity({required this.id, required this.userId, required this.type, required this.description, required this.timestamp, required this.createdAt, this.toyId, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

@override final  String id;
@override final  String userId;
@override final  ActivityType type;
@override final  String description;
@override final  DateTime timestamp;
@override final  DateTime createdAt;
@override final  String? toyId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityCopyWith<_Activity> get copyWith => __$ActivityCopyWithImpl<_Activity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,description,timestamp,createdAt,toyId,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'Activity(id: $id, userId: $userId, type: $type, description: $description, timestamp: $timestamp, createdAt: $createdAt, toyId: $toyId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory _$ActivityCopyWith(_Activity value, $Res Function(_Activity) _then) = __$ActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, ActivityType type, String description, DateTime timestamp, DateTime createdAt, String? toyId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ActivityCopyWithImpl<$Res>
    implements _$ActivityCopyWith<$Res> {
  __$ActivityCopyWithImpl(this._self, this._then);

  final _Activity _self;
  final $Res Function(_Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? description = null,Object? timestamp = null,Object? createdAt = null,Object? toyId = freezed,Object? metadata = freezed,}) {
  return _then(_Activity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$CreateActivityRequest {

 String get userId; ActivityType get type; String get description; String? get toyId; Map<String, dynamic>? get metadata; DateTime? get timestamp;
/// Create a copy of CreateActivityRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateActivityRequestCopyWith<CreateActivityRequest> get copyWith => _$CreateActivityRequestCopyWithImpl<CreateActivityRequest>(this as CreateActivityRequest, _$identity);

  /// Serializes this CreateActivityRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateActivityRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,type,description,toyId,const DeepCollectionEquality().hash(metadata),timestamp);

@override
String toString() {
  return 'CreateActivityRequest(userId: $userId, type: $type, description: $description, toyId: $toyId, metadata: $metadata, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $CreateActivityRequestCopyWith<$Res>  {
  factory $CreateActivityRequestCopyWith(CreateActivityRequest value, $Res Function(CreateActivityRequest) _then) = _$CreateActivityRequestCopyWithImpl;
@useResult
$Res call({
 String userId, ActivityType type, String description, String? toyId, Map<String, dynamic>? metadata, DateTime? timestamp
});




}
/// @nodoc
class _$CreateActivityRequestCopyWithImpl<$Res>
    implements $CreateActivityRequestCopyWith<$Res> {
  _$CreateActivityRequestCopyWithImpl(this._self, this._then);

  final CreateActivityRequest _self;
  final $Res Function(CreateActivityRequest) _then;

/// Create a copy of CreateActivityRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? type = null,Object? description = null,Object? toyId = freezed,Object? metadata = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateActivityRequest].
extension CreateActivityRequestPatterns on CreateActivityRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateActivityRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateActivityRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateActivityRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateActivityRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateActivityRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateActivityRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  ActivityType type,  String description,  String? toyId,  Map<String, dynamic>? metadata,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateActivityRequest() when $default != null:
return $default(_that.userId,_that.type,_that.description,_that.toyId,_that.metadata,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  ActivityType type,  String description,  String? toyId,  Map<String, dynamic>? metadata,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _CreateActivityRequest():
return $default(_that.userId,_that.type,_that.description,_that.toyId,_that.metadata,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  ActivityType type,  String description,  String? toyId,  Map<String, dynamic>? metadata,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _CreateActivityRequest() when $default != null:
return $default(_that.userId,_that.type,_that.description,_that.toyId,_that.metadata,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateActivityRequest implements CreateActivityRequest {
  const _CreateActivityRequest({required this.userId, required this.type, required this.description, this.toyId, final  Map<String, dynamic>? metadata, this.timestamp}): _metadata = metadata;
  factory _CreateActivityRequest.fromJson(Map<String, dynamic> json) => _$CreateActivityRequestFromJson(json);

@override final  String userId;
@override final  ActivityType type;
@override final  String description;
@override final  String? toyId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? timestamp;

/// Create a copy of CreateActivityRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateActivityRequestCopyWith<_CreateActivityRequest> get copyWith => __$CreateActivityRequestCopyWithImpl<_CreateActivityRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateActivityRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateActivityRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,type,description,toyId,const DeepCollectionEquality().hash(_metadata),timestamp);

@override
String toString() {
  return 'CreateActivityRequest(userId: $userId, type: $type, description: $description, toyId: $toyId, metadata: $metadata, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$CreateActivityRequestCopyWith<$Res> implements $CreateActivityRequestCopyWith<$Res> {
  factory _$CreateActivityRequestCopyWith(_CreateActivityRequest value, $Res Function(_CreateActivityRequest) _then) = __$CreateActivityRequestCopyWithImpl;
@override @useResult
$Res call({
 String userId, ActivityType type, String description, String? toyId, Map<String, dynamic>? metadata, DateTime? timestamp
});




}
/// @nodoc
class __$CreateActivityRequestCopyWithImpl<$Res>
    implements _$CreateActivityRequestCopyWith<$Res> {
  __$CreateActivityRequestCopyWithImpl(this._self, this._then);

  final _CreateActivityRequest _self;
  final $Res Function(_CreateActivityRequest) _then;

/// Create a copy of CreateActivityRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? type = null,Object? description = null,Object? toyId = freezed,Object? metadata = freezed,Object? timestamp = freezed,}) {
  return _then(_CreateActivityRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ActivityListResponse {

 List<Activity> get activities; int get total; int get page; int get totalPages;
/// Create a copy of ActivityListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityListResponseCopyWith<ActivityListResponse> get copyWith => _$ActivityListResponseCopyWithImpl<ActivityListResponse>(this as ActivityListResponse, _$identity);

  /// Serializes this ActivityListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityListResponse&&const DeepCollectionEquality().equals(other.activities, activities)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(activities),total,page,totalPages);

@override
String toString() {
  return 'ActivityListResponse(activities: $activities, total: $total, page: $page, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $ActivityListResponseCopyWith<$Res>  {
  factory $ActivityListResponseCopyWith(ActivityListResponse value, $Res Function(ActivityListResponse) _then) = _$ActivityListResponseCopyWithImpl;
@useResult
$Res call({
 List<Activity> activities, int total, int page, int totalPages
});




}
/// @nodoc
class _$ActivityListResponseCopyWithImpl<$Res>
    implements $ActivityListResponseCopyWith<$Res> {
  _$ActivityListResponseCopyWithImpl(this._self, this._then);

  final ActivityListResponse _self;
  final $Res Function(ActivityListResponse) _then;

/// Create a copy of ActivityListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activities = null,Object? total = null,Object? page = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<Activity>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityListResponse].
extension ActivityListResponsePatterns on ActivityListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityListResponse value)  $default,){
final _that = this;
switch (_that) {
case _ActivityListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Activity> activities,  int total,  int page,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityListResponse() when $default != null:
return $default(_that.activities,_that.total,_that.page,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Activity> activities,  int total,  int page,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _ActivityListResponse():
return $default(_that.activities,_that.total,_that.page,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Activity> activities,  int total,  int page,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _ActivityListResponse() when $default != null:
return $default(_that.activities,_that.total,_that.page,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityListResponse implements ActivityListResponse {
  const _ActivityListResponse({required final  List<Activity> activities, required this.total, required this.page, required this.totalPages}): _activities = activities;
  factory _ActivityListResponse.fromJson(Map<String, dynamic> json) => _$ActivityListResponseFromJson(json);

 final  List<Activity> _activities;
@override List<Activity> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}

@override final  int total;
@override final  int page;
@override final  int totalPages;

/// Create a copy of ActivityListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityListResponseCopyWith<_ActivityListResponse> get copyWith => __$ActivityListResponseCopyWithImpl<_ActivityListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityListResponse&&const DeepCollectionEquality().equals(other._activities, _activities)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_activities),total,page,totalPages);

@override
String toString() {
  return 'ActivityListResponse(activities: $activities, total: $total, page: $page, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$ActivityListResponseCopyWith<$Res> implements $ActivityListResponseCopyWith<$Res> {
  factory _$ActivityListResponseCopyWith(_ActivityListResponse value, $Res Function(_ActivityListResponse) _then) = __$ActivityListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Activity> activities, int total, int page, int totalPages
});




}
/// @nodoc
class __$ActivityListResponseCopyWithImpl<$Res>
    implements _$ActivityListResponseCopyWith<$Res> {
  __$ActivityListResponseCopyWithImpl(this._self, this._then);

  final _ActivityListResponse _self;
  final $Res Function(_ActivityListResponse) _then;

/// Create a copy of ActivityListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activities = null,Object? total = null,Object? page = null,Object? totalPages = null,}) {
  return _then(_ActivityListResponse(
activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<Activity>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ActivityStats {

 int get totalActivities; Map<String, int> get byType; Map<String, int> get byToy; Map<String, int> get last7Days; Map<String, int> get last30Days;
/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityStatsCopyWith<ActivityStats> get copyWith => _$ActivityStatsCopyWithImpl<ActivityStats>(this as ActivityStats, _$identity);

  /// Serializes this ActivityStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityStats&&(identical(other.totalActivities, totalActivities) || other.totalActivities == totalActivities)&&const DeepCollectionEquality().equals(other.byType, byType)&&const DeepCollectionEquality().equals(other.byToy, byToy)&&const DeepCollectionEquality().equals(other.last7Days, last7Days)&&const DeepCollectionEquality().equals(other.last30Days, last30Days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalActivities,const DeepCollectionEquality().hash(byType),const DeepCollectionEquality().hash(byToy),const DeepCollectionEquality().hash(last7Days),const DeepCollectionEquality().hash(last30Days));

@override
String toString() {
  return 'ActivityStats(totalActivities: $totalActivities, byType: $byType, byToy: $byToy, last7Days: $last7Days, last30Days: $last30Days)';
}


}

/// @nodoc
abstract mixin class $ActivityStatsCopyWith<$Res>  {
  factory $ActivityStatsCopyWith(ActivityStats value, $Res Function(ActivityStats) _then) = _$ActivityStatsCopyWithImpl;
@useResult
$Res call({
 int totalActivities, Map<String, int> byType, Map<String, int> byToy, Map<String, int> last7Days, Map<String, int> last30Days
});




}
/// @nodoc
class _$ActivityStatsCopyWithImpl<$Res>
    implements $ActivityStatsCopyWith<$Res> {
  _$ActivityStatsCopyWithImpl(this._self, this._then);

  final ActivityStats _self;
  final $Res Function(ActivityStats) _then;

/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalActivities = null,Object? byType = null,Object? byToy = null,Object? last7Days = null,Object? last30Days = null,}) {
  return _then(_self.copyWith(
totalActivities: null == totalActivities ? _self.totalActivities : totalActivities // ignore: cast_nullable_to_non_nullable
as int,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as Map<String, int>,byToy: null == byToy ? _self.byToy : byToy // ignore: cast_nullable_to_non_nullable
as Map<String, int>,last7Days: null == last7Days ? _self.last7Days : last7Days // ignore: cast_nullable_to_non_nullable
as Map<String, int>,last30Days: null == last30Days ? _self.last30Days : last30Days // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityStats].
extension ActivityStatsPatterns on ActivityStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityStats value)  $default,){
final _that = this;
switch (_that) {
case _ActivityStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityStats value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalActivities,  Map<String, int> byType,  Map<String, int> byToy,  Map<String, int> last7Days,  Map<String, int> last30Days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
return $default(_that.totalActivities,_that.byType,_that.byToy,_that.last7Days,_that.last30Days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalActivities,  Map<String, int> byType,  Map<String, int> byToy,  Map<String, int> last7Days,  Map<String, int> last30Days)  $default,) {final _that = this;
switch (_that) {
case _ActivityStats():
return $default(_that.totalActivities,_that.byType,_that.byToy,_that.last7Days,_that.last30Days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalActivities,  Map<String, int> byType,  Map<String, int> byToy,  Map<String, int> last7Days,  Map<String, int> last30Days)?  $default,) {final _that = this;
switch (_that) {
case _ActivityStats() when $default != null:
return $default(_that.totalActivities,_that.byType,_that.byToy,_that.last7Days,_that.last30Days);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityStats implements ActivityStats {
  const _ActivityStats({required this.totalActivities, required final  Map<String, int> byType, required final  Map<String, int> byToy, required final  Map<String, int> last7Days, required final  Map<String, int> last30Days}): _byType = byType,_byToy = byToy,_last7Days = last7Days,_last30Days = last30Days;
  factory _ActivityStats.fromJson(Map<String, dynamic> json) => _$ActivityStatsFromJson(json);

@override final  int totalActivities;
 final  Map<String, int> _byType;
@override Map<String, int> get byType {
  if (_byType is EqualUnmodifiableMapView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byType);
}

 final  Map<String, int> _byToy;
@override Map<String, int> get byToy {
  if (_byToy is EqualUnmodifiableMapView) return _byToy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byToy);
}

 final  Map<String, int> _last7Days;
@override Map<String, int> get last7Days {
  if (_last7Days is EqualUnmodifiableMapView) return _last7Days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_last7Days);
}

 final  Map<String, int> _last30Days;
@override Map<String, int> get last30Days {
  if (_last30Days is EqualUnmodifiableMapView) return _last30Days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_last30Days);
}


/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityStatsCopyWith<_ActivityStats> get copyWith => __$ActivityStatsCopyWithImpl<_ActivityStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityStats&&(identical(other.totalActivities, totalActivities) || other.totalActivities == totalActivities)&&const DeepCollectionEquality().equals(other._byType, _byType)&&const DeepCollectionEquality().equals(other._byToy, _byToy)&&const DeepCollectionEquality().equals(other._last7Days, _last7Days)&&const DeepCollectionEquality().equals(other._last30Days, _last30Days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalActivities,const DeepCollectionEquality().hash(_byType),const DeepCollectionEquality().hash(_byToy),const DeepCollectionEquality().hash(_last7Days),const DeepCollectionEquality().hash(_last30Days));

@override
String toString() {
  return 'ActivityStats(totalActivities: $totalActivities, byType: $byType, byToy: $byToy, last7Days: $last7Days, last30Days: $last30Days)';
}


}

/// @nodoc
abstract mixin class _$ActivityStatsCopyWith<$Res> implements $ActivityStatsCopyWith<$Res> {
  factory _$ActivityStatsCopyWith(_ActivityStats value, $Res Function(_ActivityStats) _then) = __$ActivityStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalActivities, Map<String, int> byType, Map<String, int> byToy, Map<String, int> last7Days, Map<String, int> last30Days
});




}
/// @nodoc
class __$ActivityStatsCopyWithImpl<$Res>
    implements _$ActivityStatsCopyWith<$Res> {
  __$ActivityStatsCopyWithImpl(this._self, this._then);

  final _ActivityStats _self;
  final $Res Function(_ActivityStats) _then;

/// Create a copy of ActivityStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalActivities = null,Object? byType = null,Object? byToy = null,Object? last7Days = null,Object? last30Days = null,}) {
  return _then(_ActivityStats(
totalActivities: null == totalActivities ? _self.totalActivities : totalActivities // ignore: cast_nullable_to_non_nullable
as int,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as Map<String, int>,byToy: null == byToy ? _self._byToy : byToy // ignore: cast_nullable_to_non_nullable
as Map<String, int>,last7Days: null == last7Days ? _self._last7Days : last7Days // ignore: cast_nullable_to_non_nullable
as Map<String, int>,last30Days: null == last30Days ? _self._last30Days : last30Days // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
