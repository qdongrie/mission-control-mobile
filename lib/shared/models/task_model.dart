class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final String? agent;
  final String priority; // low, medium, high
  final String status;   // backlog, todo, in_progress, in_review, done
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.agent,
    this.priority = 'medium',
    this.status = 'backlog',
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      agent: map['agent'],
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'backlog',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'agent': agent,
      'priority': priority,
      'status': status,
    };
  }

  bool get isHighPriority => priority == 'high';
  bool get isDone => status == 'done';
  bool get isInProgress => status == 'in_progress';
}
