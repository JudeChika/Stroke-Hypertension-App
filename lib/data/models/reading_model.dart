class ReadingModel {
  final String id;
  final double systolic;
  final double diastolic;
  final double riskScore;
  final DateTime timestamp;
  final double? age; // optional, captured at time of reading
  final double? bmi; // optional

  ReadingModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.riskScore,
    required this.timestamp,
    this.age,
    this.bmi,
  });

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'riskScore': riskScore,
      // store timestamp as ISO string to be portable
      'timestamp': timestamp.toIso8601String(),
      if (age != null) 'age': age,
      if (bmi != null) 'bmi': bmi,
    };
  }

  // Firestore -> ReadingModel
  factory ReadingModel.fromMap(String id, Map<String, dynamic> map) {
    // Parse timestamp robustly
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
        // Some representations: {'_seconds': 166..., '_nanoseconds': ...}
        final seconds = rawTs['_seconds'];
        final nanos = rawTs['_nanoseconds'] ?? 0;
        ts = DateTime.fromMillisecondsSinceEpoch((seconds as int) * 1000 + (nanos as int) ~/ 1000000);
      } else {
        // Many Firestore clients return a Timestamp-like object with toDate()
        try {
          ts = (rawTs as dynamic).toDate();
          if (ts is! DateTime) ts = DateTime.now();
        } catch (_) {
          ts = DateTime.now();
        }
      }
    } catch (_) {
      ts = DateTime.now();
    }

    double? ageVal;
    double? bmiVal;
    try {
      if (map.containsKey('age') && map['age'] != null) {
        ageVal = (map['age'] as num).toDouble();
      }
    } catch (_) {
      ageVal = null;
    }
    try {
      if (map.containsKey('bmi') && map['bmi'] != null) {
        bmiVal = (map['bmi'] as num).toDouble();
      }
    } catch (_) {
      bmiVal = null;
    }

    return ReadingModel(
      id: id,
      systolic: (map['systolic'] ?? 0).toDouble(),
      diastolic: (map['diastolic'] ?? 0).toDouble(),
      riskScore: (map['riskScore'] ?? 0.0).toDouble(),
      timestamp: ts,
      age: ageVal,
      bmi: bmiVal,
    );
  }
}