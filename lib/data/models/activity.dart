import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

enum ActivityType {
  @JsonValue('voice_command')
  voiceCommand,
  @JsonValue('connection')
  connection,
  @JsonValue('interaction')
  interaction,
  @JsonValue('update')
  update,
  @JsonValue('error')
  error,
  @JsonValue('play')
  play,
  @JsonValue('sleep')
  sleep,
  @JsonValue('wake')
  wake,
  @JsonValue('chat')
  chat,
}

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String userId,
    required ActivityType type,
    required String description,
    required DateTime timestamp,
    required DateTime createdAt,
    String? toyId,
    Map<String, dynamic>? metadata,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}

@freezed
abstract class CreateActivityRequest with _$CreateActivityRequest {
  const factory CreateActivityRequest({
    required String userId,
    required ActivityType type,
    required String description,
    String? toyId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) = _CreateActivityRequest;

  factory CreateActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateActivityRequestFromJson(json);
}

@freezed
abstract class ActivityListResponse with _$ActivityListResponse {
  const factory ActivityListResponse({
    required List<Activity> activities,
    required int total,
    required int page,
    required int totalPages,
  }) = _ActivityListResponse;

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityListResponseFromJson(json);
}

@freezed
abstract class ActivityStats with _$ActivityStats {
  const factory ActivityStats({
    required int totalActivities,
    required Map<String, int> byType,
    required Map<String, int> byToy,
    required Map<String, int> last7Days,
    required Map<String, int> last30Days,
  }) = _ActivityStats;

  factory ActivityStats.fromJson(Map<String, dynamic> json) =>
      _$ActivityStatsFromJson(json);
}
