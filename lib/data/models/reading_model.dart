// New file: lib/data/models/reading_model.dart
class ReadingModel {
  final String id;
  final double systolic;
  final double diastolic;
  final double riskScore;
  final DateTime timestamp;

  ReadingModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.riskScore,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'riskScore': riskScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Firestore -> ReadingModel
  factory ReadingModel.fromMap(String id, Map<String, dynamic> map) {
    // timestamp may be a Timestamp (server), string, or null
    DateTime ts;
    final rawTs = map['timestamp'];
    try {
      if (rawTs == null) {
        ts = DateTime.now();
      } else if (rawTs is String) {
        ts = DateTime.tryParse(rawTs) ?? DateTime.now();
      } else if (rawTs is DateTime) {
        ts = rawTs;
      } else if (rawTs is Map && rawTs.containsKey('_seconds')) {
        // sometimes maps come through - be defensive
        ts = DateTime.fromMillisecondsSinceEpoch((rawTs['_seconds'] as int) * 1000);
      } else {
        // Assume it's a Timestamp (from cloud_firestore)
        try {
          // Avoid importing cloud_firestore here so this is generic
          ts = (rawTs as dynamic).toDate();
        } catch (_) {
          ts = DateTime.now();
        }
      }
    } catch (_) {
      ts = DateTime.now();
    }

    return ReadingModel(
      id: id,
      systolic: (map['systolic'] ?? 0).toDouble(),
      diastolic: (map['diastolic'] ?? 0).toDouble(),
      riskScore: (map['riskScore'] ?? 0.0).toDouble(),
      timestamp: ts,
    );
  }
}