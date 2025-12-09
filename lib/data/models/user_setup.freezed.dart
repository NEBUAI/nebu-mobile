// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_setup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get name; String get email; String? get avatarUrl;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,avatarUrl);

@override
String toString() {
  return 'UserProfile(name: $name, email: $email, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String name, String email, String? avatarUrl
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.name,_that.email,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.name,_that.email,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.name,_that.email,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.name, required this.email, this.avatarUrl});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String name;
@override final  String email;
@override final  String? avatarUrl;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,avatarUrl);

@override
String toString() {
  return 'UserProfile(name: $name, email: $email, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String? avatarUrl
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? avatarUrl = freezed,}) {
  return _then(_UserProfile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserPreferences {

 String get language; String get theme; bool get hapticFeedback; bool get autoSave; bool get analytics;
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<UserPreferences> get copyWith => _$UserPreferencesCopyWithImpl<UserPreferences>(this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferences&&(identical(other.language, language) || other.language == language)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.hapticFeedback, hapticFeedback) || other.hapticFeedback == hapticFeedback)&&(identical(other.autoSave, autoSave) || other.autoSave == autoSave)&&(identical(other.analytics, analytics) || other.analytics == analytics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,theme,hapticFeedback,autoSave,analytics);

@override
String toString() {
  return 'UserPreferences(language: $language, theme: $theme, hapticFeedback: $hapticFeedback, autoSave: $autoSave, analytics: $analytics)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res>  {
  factory $UserPreferencesCopyWith(UserPreferences value, $Res Function(UserPreferences) _then) = _$UserPreferencesCopyWithImpl;
@useResult
$Res call({
 String language, String theme, bool hapticFeedback, bool autoSave, bool analytics
});




}
/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? theme = null,Object? hapticFeedback = null,Object? autoSave = null,Object? analytics = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,hapticFeedback: null == hapticFeedback ? _self.hapticFeedback : hapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,autoSave: null == autoSave ? _self.autoSave : autoSave // ignore: cast_nullable_to_non_nullable
as bool,analytics: null == analytics ? _self.analytics : analytics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreferences].
extension UserPreferencesPatterns on UserPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferences value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String language,  String theme,  bool hapticFeedback,  bool autoSave,  bool analytics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.language,_that.theme,_that.hapticFeedback,_that.autoSave,_that.analytics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String language,  String theme,  bool hapticFeedback,  bool autoSave,  bool analytics)  $default,) {final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that.language,_that.theme,_that.hapticFeedback,_that.autoSave,_that.analytics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String language,  String theme,  bool hapticFeedback,  bool autoSave,  bool analytics)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.language,_that.theme,_that.hapticFeedback,_that.autoSave,_that.analytics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferences implements UserPreferences {
  const _UserPreferences({required this.language, required this.theme, this.hapticFeedback = true, this.autoSave = true, this.analytics = false});
  factory _UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);

@override final  String language;
@override final  String theme;
@override@JsonKey() final  bool hapticFeedback;
@override@JsonKey() final  bool autoSave;
@override@JsonKey() final  bool analytics;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesCopyWith<_UserPreferences> get copyWith => __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferences&&(identical(other.language, language) || other.language == language)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.hapticFeedback, hapticFeedback) || other.hapticFeedback == hapticFeedback)&&(identical(other.autoSave, autoSave) || other.autoSave == autoSave)&&(identical(other.analytics, analytics) || other.analytics == analytics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,theme,hapticFeedback,autoSave,analytics);

@override
String toString() {
  return 'UserPreferences(language: $language, theme: $theme, hapticFeedback: $hapticFeedback, autoSave: $autoSave, analytics: $analytics)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res> implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(_UserPreferences value, $Res Function(_UserPreferences) _then) = __$UserPreferencesCopyWithImpl;
@override @useResult
$Res call({
 String language, String theme, bool hapticFeedback, bool autoSave, bool analytics
});




}
/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? theme = null,Object? hapticFeedback = null,Object? autoSave = null,Object? analytics = null,}) {
  return _then(_UserPreferences(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,hapticFeedback: null == hapticFeedback ? _self.hapticFeedback : hapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,autoSave: null == autoSave ? _self.autoSave : autoSave // ignore: cast_nullable_to_non_nullable
as bool,analytics: null == analytics ? _self.analytics : analytics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$NotificationSettings {

 bool get push; bool get reminders; bool get voice; bool get updates; bool get marketing; String? get quietHoursStart; String? get quietHoursEnd;
/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<NotificationSettings> get copyWith => _$NotificationSettingsCopyWithImpl<NotificationSettings>(this as NotificationSettings, _$identity);

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&(identical(other.push, push) || other.push == push)&&(identical(other.reminders, reminders) || other.reminders == reminders)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.updates, updates) || other.updates == updates)&&(identical(other.marketing, marketing) || other.marketing == marketing)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,push,reminders,voice,updates,marketing,quietHoursStart,quietHoursEnd);

@override
String toString() {
  return 'NotificationSettings(push: $push, reminders: $reminders, voice: $voice, updates: $updates, marketing: $marketing, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
 bool push, bool reminders, bool voice, bool updates, bool marketing, String? quietHoursStart, String? quietHoursEnd
});




}
/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._self, this._then);

  final NotificationSettings _self;
  final $Res Function(NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? push = null,Object? reminders = null,Object? voice = null,Object? updates = null,Object? marketing = null,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,}) {
  return _then(_self.copyWith(
push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as bool,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as bool,voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as bool,updates: null == updates ? _self.updates : updates // ignore: cast_nullable_to_non_nullable
as bool,marketing: null == marketing ? _self.marketing : marketing // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettings].
extension NotificationSettingsPatterns on NotificationSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool push,  bool reminders,  bool voice,  bool updates,  bool marketing,  String? quietHoursStart,  String? quietHoursEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.push,_that.reminders,_that.voice,_that.updates,_that.marketing,_that.quietHoursStart,_that.quietHoursEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool push,  bool reminders,  bool voice,  bool updates,  bool marketing,  String? quietHoursStart,  String? quietHoursEnd)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.push,_that.reminders,_that.voice,_that.updates,_that.marketing,_that.quietHoursStart,_that.quietHoursEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool push,  bool reminders,  bool voice,  bool updates,  bool marketing,  String? quietHoursStart,  String? quietHoursEnd)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.push,_that.reminders,_that.voice,_that.updates,_that.marketing,_that.quietHoursStart,_that.quietHoursEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings implements NotificationSettings {
  const _NotificationSettings({this.push = true, this.reminders = true, this.voice = true, this.updates = true, this.marketing = false, this.quietHoursStart, this.quietHoursEnd});
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

@override@JsonKey() final  bool push;
@override@JsonKey() final  bool reminders;
@override@JsonKey() final  bool voice;
@override@JsonKey() final  bool updates;
@override@JsonKey() final  bool marketing;
@override final  String? quietHoursStart;
@override final  String? quietHoursEnd;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsCopyWith<_NotificationSettings> get copyWith => __$NotificationSettingsCopyWithImpl<_NotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&(identical(other.push, push) || other.push == push)&&(identical(other.reminders, reminders) || other.reminders == reminders)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.updates, updates) || other.updates == updates)&&(identical(other.marketing, marketing) || other.marketing == marketing)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,push,reminders,voice,updates,marketing,quietHoursStart,quietHoursEnd);

@override
String toString() {
  return 'NotificationSettings(push: $push, reminders: $reminders, voice: $voice, updates: $updates, marketing: $marketing, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool push, bool reminders, bool voice, bool updates, bool marketing, String? quietHoursStart, String? quietHoursEnd
});




}
/// @nodoc
class __$NotificationSettingsCopyWithImpl<$Res>
    implements _$NotificationSettingsCopyWith<$Res> {
  __$NotificationSettingsCopyWithImpl(this._self, this._then);

  final _NotificationSettings _self;
  final $Res Function(_NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? push = null,Object? reminders = null,Object? voice = null,Object? updates = null,Object? marketing = null,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,}) {
  return _then(_NotificationSettings(
push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as bool,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as bool,voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as bool,updates: null == updates ? _self.updates : updates // ignore: cast_nullable_to_non_nullable
as bool,marketing: null == marketing ? _self.marketing : marketing // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceSettings {

 bool get enabled; String? get voiceModel; double get speechRate;
/// Create a copy of VoiceSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceSettingsCopyWith<VoiceSettings> get copyWith => _$VoiceSettingsCopyWithImpl<VoiceSettings>(this as VoiceSettings, _$identity);

  /// Serializes this VoiceSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.voiceModel, voiceModel) || other.voiceModel == voiceModel)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,voiceModel,speechRate);

@override
String toString() {
  return 'VoiceSettings(enabled: $enabled, voiceModel: $voiceModel, speechRate: $speechRate)';
}


}

/// @nodoc
abstract mixin class $VoiceSettingsCopyWith<$Res>  {
  factory $VoiceSettingsCopyWith(VoiceSettings value, $Res Function(VoiceSettings) _then) = _$VoiceSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? voiceModel, double speechRate
});




}
/// @nodoc
class _$VoiceSettingsCopyWithImpl<$Res>
    implements $VoiceSettingsCopyWith<$Res> {
  _$VoiceSettingsCopyWithImpl(this._self, this._then);

  final VoiceSettings _self;
  final $Res Function(VoiceSettings) _then;

/// Create a copy of VoiceSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? voiceModel = freezed,Object? speechRate = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,voiceModel: freezed == voiceModel ? _self.voiceModel : voiceModel // ignore: cast_nullable_to_non_nullable
as String?,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceSettings].
extension VoiceSettingsPatterns on VoiceSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceSettings value)  $default,){
final _that = this;
switch (_that) {
case _VoiceSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceSettings value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? voiceModel,  double speechRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceSettings() when $default != null:
return $default(_that.enabled,_that.voiceModel,_that.speechRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? voiceModel,  double speechRate)  $default,) {final _that = this;
switch (_that) {
case _VoiceSettings():
return $default(_that.enabled,_that.voiceModel,_that.speechRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? voiceModel,  double speechRate)?  $default,) {final _that = this;
switch (_that) {
case _VoiceSettings() when $default != null:
return $default(_that.enabled,_that.voiceModel,_that.speechRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceSettings implements VoiceSettings {
  const _VoiceSettings({this.enabled = true, this.voiceModel, this.speechRate = 1.0});
  factory _VoiceSettings.fromJson(Map<String, dynamic> json) => _$VoiceSettingsFromJson(json);

@override@JsonKey() final  bool enabled;
@override final  String? voiceModel;
@override@JsonKey() final  double speechRate;

/// Create a copy of VoiceSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceSettingsCopyWith<_VoiceSettings> get copyWith => __$VoiceSettingsCopyWithImpl<_VoiceSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.voiceModel, voiceModel) || other.voiceModel == voiceModel)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,voiceModel,speechRate);

@override
String toString() {
  return 'VoiceSettings(enabled: $enabled, voiceModel: $voiceModel, speechRate: $speechRate)';
}


}

/// @nodoc
abstract mixin class _$VoiceSettingsCopyWith<$Res> implements $VoiceSettingsCopyWith<$Res> {
  factory _$VoiceSettingsCopyWith(_VoiceSettings value, $Res Function(_VoiceSettings) _then) = __$VoiceSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? voiceModel, double speechRate
});




}
/// @nodoc
class __$VoiceSettingsCopyWithImpl<$Res>
    implements _$VoiceSettingsCopyWith<$Res> {
  __$VoiceSettingsCopyWithImpl(this._self, this._then);

  final _VoiceSettings _self;
  final $Res Function(_VoiceSettings) _then;

/// Create a copy of VoiceSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? voiceModel = freezed,Object? speechRate = null,}) {
  return _then(_VoiceSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,voiceModel: freezed == voiceModel ? _self.voiceModel : voiceModel // ignore: cast_nullable_to_non_nullable
as String?,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$UserSetup {

 UserProfile get profile; UserPreferences get preferences; NotificationSettings get notifications; VoiceSettings get voice; bool get setupCompleted;
/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSetupCopyWith<UserSetup> get copyWith => _$UserSetupCopyWithImpl<UserSetup>(this as UserSetup, _$identity);

  /// Serializes this UserSetup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSetup&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.setupCompleted, setupCompleted) || other.setupCompleted == setupCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile,preferences,notifications,voice,setupCompleted);

@override
String toString() {
  return 'UserSetup(profile: $profile, preferences: $preferences, notifications: $notifications, voice: $voice, setupCompleted: $setupCompleted)';
}


}

/// @nodoc
abstract mixin class $UserSetupCopyWith<$Res>  {
  factory $UserSetupCopyWith(UserSetup value, $Res Function(UserSetup) _then) = _$UserSetupCopyWithImpl;
@useResult
$Res call({
 UserProfile profile, UserPreferences preferences, NotificationSettings notifications, VoiceSettings voice, bool setupCompleted
});


$UserProfileCopyWith<$Res> get profile;$UserPreferencesCopyWith<$Res> get preferences;$NotificationSettingsCopyWith<$Res> get notifications;$VoiceSettingsCopyWith<$Res> get voice;

}
/// @nodoc
class _$UserSetupCopyWithImpl<$Res>
    implements $UserSetupCopyWith<$Res> {
  _$UserSetupCopyWithImpl(this._self, this._then);

  final UserSetup _self;
  final $Res Function(UserSetup) _then;

/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? preferences = null,Object? notifications = null,Object? voice = null,Object? setupCompleted = null,}) {
  return _then(_self.copyWith(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as NotificationSettings,voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as VoiceSettings,setupCompleted: null == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notifications {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notifications, (value) {
    return _then(_self.copyWith(notifications: value));
  });
}/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoiceSettingsCopyWith<$Res> get voice {
  
  return $VoiceSettingsCopyWith<$Res>(_self.voice, (value) {
    return _then(_self.copyWith(voice: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSetup].
extension UserSetupPatterns on UserSetup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSetup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSetup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSetup value)  $default,){
final _that = this;
switch (_that) {
case _UserSetup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSetup value)?  $default,){
final _that = this;
switch (_that) {
case _UserSetup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserProfile profile,  UserPreferences preferences,  NotificationSettings notifications,  VoiceSettings voice,  bool setupCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSetup() when $default != null:
return $default(_that.profile,_that.preferences,_that.notifications,_that.voice,_that.setupCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserProfile profile,  UserPreferences preferences,  NotificationSettings notifications,  VoiceSettings voice,  bool setupCompleted)  $default,) {final _that = this;
switch (_that) {
case _UserSetup():
return $default(_that.profile,_that.preferences,_that.notifications,_that.voice,_that.setupCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserProfile profile,  UserPreferences preferences,  NotificationSettings notifications,  VoiceSettings voice,  bool setupCompleted)?  $default,) {final _that = this;
switch (_that) {
case _UserSetup() when $default != null:
return $default(_that.profile,_that.preferences,_that.notifications,_that.voice,_that.setupCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSetup implements UserSetup {
  const _UserSetup({required this.profile, required this.preferences, required this.notifications, required this.voice, this.setupCompleted = false});
  factory _UserSetup.fromJson(Map<String, dynamic> json) => _$UserSetupFromJson(json);

@override final  UserProfile profile;
@override final  UserPreferences preferences;
@override final  NotificationSettings notifications;
@override final  VoiceSettings voice;
@override@JsonKey() final  bool setupCompleted;

/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSetupCopyWith<_UserSetup> get copyWith => __$UserSetupCopyWithImpl<_UserSetup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSetupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSetup&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.setupCompleted, setupCompleted) || other.setupCompleted == setupCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile,preferences,notifications,voice,setupCompleted);

@override
String toString() {
  return 'UserSetup(profile: $profile, preferences: $preferences, notifications: $notifications, voice: $voice, setupCompleted: $setupCompleted)';
}


}

/// @nodoc
abstract mixin class _$UserSetupCopyWith<$Res> implements $UserSetupCopyWith<$Res> {
  factory _$UserSetupCopyWith(_UserSetup value, $Res Function(_UserSetup) _then) = __$UserSetupCopyWithImpl;
@override @useResult
$Res call({
 UserProfile profile, UserPreferences preferences, NotificationSettings notifications, VoiceSettings voice, bool setupCompleted
});


@override $UserProfileCopyWith<$Res> get profile;@override $UserPreferencesCopyWith<$Res> get preferences;@override $NotificationSettingsCopyWith<$Res> get notifications;@override $VoiceSettingsCopyWith<$Res> get voice;

}
/// @nodoc
class __$UserSetupCopyWithImpl<$Res>
    implements _$UserSetupCopyWith<$Res> {
  __$UserSetupCopyWithImpl(this._self, this._then);

  final _UserSetup _self;
  final $Res Function(_UserSetup) _then;

/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? preferences = null,Object? notifications = null,Object? voice = null,Object? setupCompleted = null,}) {
  return _then(_UserSetup(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as NotificationSettings,voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as VoiceSettings,setupCompleted: null == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<$Res> get notifications {
  
  return $NotificationSettingsCopyWith<$Res>(_self.notifications, (value) {
    return _then(_self.copyWith(notifications: value));
  });
}/// Create a copy of UserSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoiceSettingsCopyWith<$Res> get voice {
  
  return $VoiceSettingsCopyWith<$Res>(_self.voice, (value) {
    return _then(_self.copyWith(voice: value));
  });
}
}


/// @nodoc
mixin _$SetupResponse {

 bool get success; String get message; bool get setupCompleted; UserSetup? get setup;
/// Create a copy of SetupResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupResponseCopyWith<SetupResponse> get copyWith => _$SetupResponseCopyWithImpl<SetupResponse>(this as SetupResponse, _$identity);

  /// Serializes this SetupResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.setupCompleted, setupCompleted) || other.setupCompleted == setupCompleted)&&(identical(other.setup, setup) || other.setup == setup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,setupCompleted,setup);

@override
String toString() {
  return 'SetupResponse(success: $success, message: $message, setupCompleted: $setupCompleted, setup: $setup)';
}


}

/// @nodoc
abstract mixin class $SetupResponseCopyWith<$Res>  {
  factory $SetupResponseCopyWith(SetupResponse value, $Res Function(SetupResponse) _then) = _$SetupResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String message, bool setupCompleted, UserSetup? setup
});


$UserSetupCopyWith<$Res>? get setup;

}
/// @nodoc
class _$SetupResponseCopyWithImpl<$Res>
    implements $SetupResponseCopyWith<$Res> {
  _$SetupResponseCopyWithImpl(this._self, this._then);

  final SetupResponse _self;
  final $Res Function(SetupResponse) _then;

/// Create a copy of SetupResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = null,Object? setupCompleted = null,Object? setup = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,setupCompleted: null == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool,setup: freezed == setup ? _self.setup : setup // ignore: cast_nullable_to_non_nullable
as UserSetup?,
  ));
}
/// Create a copy of SetupResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSetupCopyWith<$Res>? get setup {
    if (_self.setup == null) {
    return null;
  }

  return $UserSetupCopyWith<$Res>(_self.setup!, (value) {
    return _then(_self.copyWith(setup: value));
  });
}
}


/// Adds pattern-matching-related methods to [SetupResponse].
extension SetupResponsePatterns on SetupResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupResponse value)  $default,){
final _that = this;
switch (_that) {
case _SetupResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SetupResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String message,  bool setupCompleted,  UserSetup? setup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupResponse() when $default != null:
return $default(_that.success,_that.message,_that.setupCompleted,_that.setup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String message,  bool setupCompleted,  UserSetup? setup)  $default,) {final _that = this;
switch (_that) {
case _SetupResponse():
return $default(_that.success,_that.message,_that.setupCompleted,_that.setup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String message,  bool setupCompleted,  UserSetup? setup)?  $default,) {final _that = this;
switch (_that) {
case _SetupResponse() when $default != null:
return $default(_that.success,_that.message,_that.setupCompleted,_that.setup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupResponse implements SetupResponse {
  const _SetupResponse({required this.success, required this.message, required this.setupCompleted, this.setup});
  factory _SetupResponse.fromJson(Map<String, dynamic> json) => _$SetupResponseFromJson(json);

@override final  bool success;
@override final  String message;
@override final  bool setupCompleted;
@override final  UserSetup? setup;

/// Create a copy of SetupResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupResponseCopyWith<_SetupResponse> get copyWith => __$SetupResponseCopyWithImpl<_SetupResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetupResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.setupCompleted, setupCompleted) || other.setupCompleted == setupCompleted)&&(identical(other.setup, setup) || other.setup == setup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,setupCompleted,setup);

@override
String toString() {
  return 'SetupResponse(success: $success, message: $message, setupCompleted: $setupCompleted, setup: $setup)';
}


}

/// @nodoc
abstract mixin class _$SetupResponseCopyWith<$Res> implements $SetupResponseCopyWith<$Res> {
  factory _$SetupResponseCopyWith(_SetupResponse value, $Res Function(_SetupResponse) _then) = __$SetupResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String message, bool setupCompleted, UserSetup? setup
});


@override $UserSetupCopyWith<$Res>? get setup;

}
/// @nodoc
class __$SetupResponseCopyWithImpl<$Res>
    implements _$SetupResponseCopyWith<$Res> {
  __$SetupResponseCopyWithImpl(this._self, this._then);

  final _SetupResponse _self;
  final $Res Function(_SetupResponse) _then;

/// Create a copy of SetupResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = null,Object? setupCompleted = null,Object? setup = freezed,}) {
  return _then(_SetupResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,setupCompleted: null == setupCompleted ? _self.setupCompleted : setupCompleted // ignore: cast_nullable_to_non_nullable
as bool,setup: freezed == setup ? _self.setup : setup // ignore: cast_nullable_to_non_nullable
as UserSetup?,
  ));
}

/// Create a copy of SetupResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSetupCopyWith<$Res>? get setup {
    if (_self.setup == null) {
    return null;
  }

  return $UserSetupCopyWith<$Res>(_self.setup!, (value) {
    return _then(_self.copyWith(setup: value));
  });
}
}

// dart format on
