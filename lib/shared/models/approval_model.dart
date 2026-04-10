class ApprovalModel {
  final int? id;
  final String type;       // content, code, decision
  final String? preview;
  final String agent;
  final String status;      // pending, approved, rejected
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApprovalModel({
    this.id,
    required this.type,
    this.preview,
    required this.agent,
    this.status = 'pending',
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  factory ApprovalModel.fromMap(Map<String, dynamic> map) {
    return ApprovalModel(
      id: map['id'],
      type: map['type'] ?? '',
      preview: map['preview'],
      agent: map['agent'] ?? '',
      status: map['status'] ?? 'pending',
      reason: map['reason'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'preview': preview,
      'agent': agent,
      'status': status,
      'reason': reason,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get typeIcon {
    switch (type) {
      case 'content': return '📝';
      case 'code': return '💻';
      case 'decision': return '🎯';
      default: return '📋';
    }
  }
}
