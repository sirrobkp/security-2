class Alert {
  final String id;
  final String type; // 'intrusion', 'fire', 'weapon'
  final int confidence;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.type,
    required this.confidence,
    required this.timestamp,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      type: json['type'],
      confidence: json['confidence'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
