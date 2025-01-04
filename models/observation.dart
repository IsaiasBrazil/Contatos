class Observation {
  final int? id;
  late final int clientId;
  final String content;
  final DateTime timestamp;

  Observation({
    this.id,
    required this.clientId,
    required this.content,
    required this.timestamp,
  });

  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id'],
      clientId: map['clientId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
