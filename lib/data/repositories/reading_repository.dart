import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final readingRepositoryProvider = Provider((ref) => ReadingRepository());

class ReadingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveReading({
    required double systolic,
    required double diastolic,
    required double riskScore, // The result from ML model
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw "User not logged in";

    try {
      // Create a reading object
      final readingData = {
        'systolic': systolic,
        'diastolic': diastolic,
        'riskScore': riskScore,
        'timestamp': FieldValue.serverTimestamp(),
        'status': riskScore > 0.7 ? 'High' : (riskScore > 0.4 ? 'Moderate' : 'Low'),
      };

      // Save to sub-collection: users/{uid}/readings/{readingId}
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('readings')
          .add(readingData);

    } catch (e) {
      throw "Failed to save reading: $e";
    }
  }
}