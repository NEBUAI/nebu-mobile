// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_setup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
    };

_UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    _UserPreferences(
      language: json['language'] as String,
      theme: json['theme'] as String,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? true,
      analytics: json['analytics'] as bool? ?? false,
    );

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'theme': instance.theme,
      'hapticFeedback': instance.hapticFeedback,
      'autoSave': instance.autoSave,
      'analytics': instance.analytics,
    };

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  push: json['push'] as bool? ?? true,
  reminders: json['reminders'] as bool? ?? true,
  voice: json['voice'] as bool? ?? true,
  updates: json['updates'] as bool? ?? true,
  marketing: json['marketing'] as bool? ?? false,
  quietHoursStart: json['quietHoursStart'] as String?,
  quietHoursEnd: json['quietHoursEnd'] as String?,
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'push': instance.push,
  'reminders': instance.reminders,
  'voice': instance.voice,
  'updates': instance.updates,
  'marketing': instance.marketing,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
};

_VoiceSettings _$VoiceSettingsFromJson(Map<String, dynamic> json) =>
    _VoiceSettings(
      enabled: json['enabled'] as bool? ?? true,
      voiceModel: json['voiceModel'] as String?,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$VoiceSettingsToJson(_VoiceSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'voiceModel': instance.voiceModel,
      'speechRate': instance.speechRate,
    };

_UserSetup _$UserSetupFromJson(Map<String, dynamic> json) => _UserSetup(
  profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
  preferences: UserPreferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
  notifications: NotificationSettings.fromJson(
    json['notifications'] as Map<String, dynamic>,
  ),
  voice: VoiceSettings.fromJson(json['voice'] as Map<String, dynamic>),
  setupCompleted: json['setupCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$UserSetupToJson(_UserSetup instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'preferences': instance.preferences,
      'notifications': instance.notifications,
      'voice': instance.voice,
      'setupCompleted': instance.setupCompleted,
    };

_SetupResponse _$SetupResponseFromJson(Map<String, dynamic> json) =>
    _SetupResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      setupCompleted: json['setupCompleted'] as bool,
      setup: json['setup'] == null
          ? null
          : UserSetup.fromJson(json['setup'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SetupResponseToJson(_SetupResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'setupCompleted': instance.setupCompleted,
      'setup': instance.setup,
    };
