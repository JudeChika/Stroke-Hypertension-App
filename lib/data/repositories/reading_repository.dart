// Replace file at lib/data/repositories/reading_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_model.dart';

// Provider for DI
final readingRepositoryProvider = Provider((ref) => ReadingRepository());

class ReadingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save reading and optionally update user's profile with age & bmi
  Future<void> saveReading({
    required double systolic,
    required double diastolic,
    required double riskScore,
    double? age,
    double? bmi,
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

      if (age != null) readingData['age'] = age;
      if (bmi != null) readingData['bmi'] = bmi;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('readings')
          .add(readingData);

      // Optionally update the user document with latest age & bmi so profile contains them
      final Map<String, dynamic> userUpdate = {};
      if (age != null) userUpdate['age'] = age;
      if (bmi != null) userUpdate['bmi'] = bmi;
      if (userUpdate.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).set(userUpdate, SetOptions(merge: true));
      }
    } catch (e) {
      throw "Failed to save reading: $e";
    }
  }

  // Real-time stream of recent readings (for dashboard/live updates)
  Stream<List<ReadingModel>> readingsStream({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) {
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
        final raw = doc.data();
        final Map<String, dynamic> data = raw is Map<String, dynamic>
            ? raw
            : Map<String, dynamic>.from(raw as Map);
        return ReadingModel.fromMap(doc.id, data);
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
    final raw = doc.data();
    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    return ReadingModel.fromMap(doc.id, data);
  }

  // Fetch a page of readings using an optional timestamp cursor (timestamp of last item)
  // If startAfterTimestamp is provided, fetch readings with timestamp < that timestamp (since we order descending)
  Future<List<ReadingModel>> getReadingsPage({
    DateTime? startAfterTimestamp,
    int limit = 20,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    Query col = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfterTimestamp != null) {
      // Use Timestamp to start after the provided timestamp
      final ts = Timestamp.fromDate(startAfterTimestamp);
      col = col.startAfter([ts]);
    }

    final snapshot = await col.get();
    return snapshot.docs.map((d) {
      final raw = d.data();
      final Map<String, dynamic> data = raw is Map<String, dynamic>
          ? raw
          : Map<String, dynamic>.from(raw as Map);
      return ReadingModel.fromMap(d.id, data);
    }).toList();
  }
}