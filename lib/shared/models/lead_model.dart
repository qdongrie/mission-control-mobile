class LeadModel {
  final int? id;
  final String name;
  final String? company;
  final String? sector;
  final String? location;
  final String? size;
  final double score;
  final String status;    // new, contacted, qualified, proposal, won, lost
  final String? source;
  final DateTime? createdAt;

  LeadModel({
    this.id,
    required this.name,
    this.company,
    this.sector,
    this.location,
    this.size,
    this.score = 0,
    this.status = 'new',
    this.source,
    this.createdAt,
  });

  factory LeadModel.fromMap(Map<String, dynamic> map) {
    return LeadModel(
      id: map['id'],
      name: map['name'] ?? '',
      company: map['company'],
      sector: map['sector'],
      location: map['location'],
      size: map['size'],
      score: (map['score'] ?? 0).toDouble(),
      status: map['status'] ?? 'new',
      source: map['source'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'company': company,
      'sector': sector,
      'location': location,
      'size': size,
      'score': score,
      'status': status,
      'source': source,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'new': return '🆕';
      case 'contacted': return '📧';
      case 'qualified': return '✅';
      case 'proposal': return '📄';
      case 'won': return '🎉';
      case 'lost': return '❌';
      default: return '📋';
    }
  }
}
