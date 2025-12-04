import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_model.dart';

// Provider stays the same for DI via Riverpod
final readingRepositoryProvider = Provider((ref) => ReadingRepository());

class ReadingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveReading({
    required double systolic,
    required double diastolic,
    required double riskScore,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw "User not logged in";

    try {
      final readingData = {
        'systolic': systolic,
        'diastolic': diastolic,
        'riskScore': riskScore,
        'timestamp': FieldValue.serverTimestamp(),
        'status': riskScore > 0.7 ? 'High' : (riskScore > 0.4 ? 'Moderate' : 'Low'),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('readings')
          .add(readingData);
    } catch (e) {
      throw "Failed to save reading: $e";
    }
  }

  // New: stream of recent readings for the currently signed-in user
  Stream<List<ReadingModel>> readingsStream({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) {
      // If no user, return empty stream
      return Stream.value(<ReadingModel>[]).asBroadcastStream();
    }

    final col = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    return col.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReadingModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Convenience: get the latest reading once
  Future<ReadingModel?> getLatestReading() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return ReadingModel.fromMap(doc.id, doc.data());
  }
}