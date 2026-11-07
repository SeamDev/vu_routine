class ScheduleModel {
  final String id;
  final String topic;
  final String detail;
  final DateTime scheduledAt;
  final bool hasSpecificTime;

  ScheduleModel({
    required this.id,
    required this.topic,
    required this.detail,
    required this.scheduledAt,
    this.hasSpecificTime = true,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'].toString(),
      topic: json['topic'] ?? '',
      detail: json['detail'] ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at']).toLocal(),
      hasSpecificTime: json['has_specific_time'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'detail': detail,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'has_specific_time': hasSpecificTime,
    };
  }
}