// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Activity _$ActivityFromJson(Map<String, dynamic> json) => _Activity(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  description: json['description'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  toyId: json['toyId'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ActivityToJson(_Activity instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$ActivityTypeEnumMap[instance.type]!,
  'description': instance.description,
  'timestamp': instance.timestamp.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'toyId': instance.toyId,
  'metadata': instance.metadata,
};

const _$ActivityTypeEnumMap = {
  ActivityType.voiceCommand: 'voice_command',
  ActivityType.connection: 'connection',
  ActivityType.interaction: 'interaction',
  ActivityType.update: 'update',
  ActivityType.error: 'error',
  ActivityType.play: 'play',
  ActivityType.sleep: 'sleep',
  ActivityType.wake: 'wake',
  ActivityType.chat: 'chat',
};

_CreateActivityRequest _$CreateActivityRequestFromJson(
  Map<String, dynamic> json,
) => _CreateActivityRequest(
  userId: json['userId'] as String,
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  description: json['description'] as String,
  toyId: json['toyId'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$CreateActivityRequestToJson(
  _CreateActivityRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'type': _$ActivityTypeEnumMap[instance.type]!,
  'description': instance.description,
  'toyId': instance.toyId,
  'metadata': instance.metadata,
  'timestamp': instance.timestamp?.toIso8601String(),
};

_ActivityListResponse _$ActivityListResponseFromJson(
  Map<String, dynamic> json,
) => _ActivityListResponse(
  activities: (json['activities'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$ActivityListResponseToJson(
  _ActivityListResponse instance,
) => <String, dynamic>{
  'activities': instance.activities,
  'total': instance.total,
  'page': instance.page,
  'totalPages': instance.totalPages,
};

_ActivityStats _$ActivityStatsFromJson(Map<String, dynamic> json) =>
    _ActivityStats(
      totalActivities: (json['totalActivities'] as num).toInt(),
      byType: Map<String, int>.from(json['byType'] as Map),
      byToy: Map<String, int>.from(json['byToy'] as Map),
      last7Days: Map<String, int>.from(json['last7Days'] as Map),
      last30Days: Map<String, int>.from(json['last30Days'] as Map),
    );

Map<String, dynamic> _$ActivityStatsToJson(_ActivityStats instance) =>
    <String, dynamic>{
      'totalActivities': instance.totalActivities,
      'byType': instance.byType,
      'byToy': instance.byToy,
      'last7Days': instance.last7Days,
      'last30Days': instance.last30Days,
    };
