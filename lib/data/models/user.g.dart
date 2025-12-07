// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  username: json['username'] as String?,
  avatar: json['avatar'] as String?,
  role: json['role'] as String?,
  status: json['status'] as String?,
  emailVerified: json['emailVerified'] as bool?,
  preferredLanguage: json['preferredLanguage'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'avatar': instance.avatar,
  'role': instance.role,
  'status': instance.status,
  'emailVerified': instance.emailVerified,
  'preferredLanguage': instance.preferredLanguage,
  'createdAt': instance.createdAt?.toIso8601String(),
  'fullName': instance.fullName,
};

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
