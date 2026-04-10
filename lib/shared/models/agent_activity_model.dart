class AgentActivityModel {
  final int? id;
  final String agent;
  final String? sessionKey;
  final String taskName;
  final String status;    // working, done, error
  final String? model;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  AgentActivityModel({
    this.id,
    required this.agent,
    this.sessionKey,
    required this.taskName,
    this.status = 'working',
    this.model,
    this.startedAt,
    this.finishedAt,
  });

  factory AgentActivityModel.fromMap(Map<String, dynamic> map) {
    return AgentActivityModel(
      id: map['id'],
      agent: map['agent'] ?? '',
      sessionKey: map['session_key'],
      taskName: map['task_name'] ?? '',
      status: map['status'] ?? 'working',
      model: map['model'],
      startedAt: map['started_at'] != null ? DateTime.parse(map['started_at']) : null,
      finishedAt: map['finished_at'] != null ? DateTime.parse(map['finished_at']) : null,
    );
  }

  bool get isWorking => status == 'working';
  bool get isDone => status == 'done';
  bool get hasError => status == 'error';

  Duration? get duration {
    if (startedAt == null) return null;
    final end = finishedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  String get durationString {
    final d = duration;
    if (d == null) return '--';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}
