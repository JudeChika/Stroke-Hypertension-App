import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream the current user's document as a UserModel.
  /// Returns Stream.value(null) if no user is signed in.
  Stream<UserModel?> userStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null).asBroadcastStream();

    final docRef = _firestore.collection('users').doc(user.uid);
    return docRef.snapshots().map((snap) {
      final raw = snap.data();
      if (!snap.exists || raw == null) return null;

      final Map<String, dynamic> data = raw is Map<String, dynamic>
          ? raw
          : Map<String, dynamic>.from(raw as Map);
      // Ensure uid is available to the model
      data['uid'] = data['uid'] ?? snap.id;
      return UserModel.fromMap(data);
    });
  }

  /// One-time fetch of the current user document.
  Future<UserModel?> getUserOnce() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snap = await _firestore.collection('users').doc(user.uid).get();
    if (!snap.exists || snap.data() == null) return null;

    final raw = snap.data()!;
    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    data['uid'] = data['uid'] ?? snap.id;
    return UserModel.fromMap(data);
  }
}