import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    User? user,
    AuthTokens? tokens,
    String? error,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class SocialAuthResult with _$SocialAuthResult {
  const factory SocialAuthResult({
    required bool success,
    User? user,
    AuthTokens? tokens,
    String? error,
    appleCredential,
  }) = _SocialAuthResult;

  factory SocialAuthResult.fromJson(Map<String, dynamic> json) =>
      _$SocialAuthResultFromJson(json);
}
