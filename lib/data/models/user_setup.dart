import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_setup.freezed.dart';
part 'user_setup.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String language,
    required String theme,
    @Default(true) bool hapticFeedback,
    @Default(true) bool autoSave,
    @Default(false) bool analytics,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
abstract class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool push,
    @Default(true) bool reminders,
    @Default(true) bool voice,
    @Default(true) bool updates,
    @Default(false) bool marketing,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}

@freezed
abstract class VoiceSettings with _$VoiceSettings {
  const factory VoiceSettings({
    @Default(true) bool enabled,
    String? voiceModel,
    @Default(1.0) double speechRate,
  }) = _VoiceSettings;

  factory VoiceSettings.fromJson(Map<String, dynamic> json) =>
      _$VoiceSettingsFromJson(json);
}

@freezed
abstract class UserSetup with _$UserSetup {
  const factory UserSetup({
    required UserProfile profile,
    required UserPreferences preferences,
    required NotificationSettings notifications,
    required VoiceSettings voice,
    @Default(false) bool setupCompleted,
  }) = _UserSetup;

  factory UserSetup.fromJson(Map<String, dynamic> json) =>
      _$UserSetupFromJson(json);
}

@freezed
abstract class SetupResponse with _$SetupResponse {
  const factory SetupResponse({
    required bool success,
    required String message,
    required bool setupCompleted,
    UserSetup? setup,
  }) = _SetupResponse;

  factory SetupResponse.fromJson(Map<String, dynamic> json) =>
      _$SetupResponseFromJson(json);
}
