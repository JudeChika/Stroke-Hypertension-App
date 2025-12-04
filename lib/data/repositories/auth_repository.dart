import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// --- Riverpod Provider ---
final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Get Current User ---
  User? get currentUser => _auth.currentUser;

  // --- Sign Up ---
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      log("🔄 Attempting to create user: $email");
      // 1. Create Auth User
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      log("✅ Auth User Created: ${result.user!.uid}");

      // 2. Create User Document in Firestore
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        fullName: fullName,
      );

      log("🔄 Saving user to Firestore...");
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap());

      log("✅ User Saved to Firestore: ${result.user!.uid}");
    } on FirebaseAuthException catch (e) {
      log("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      throw _handleAuthError(e);
    } catch (e, stackTrace) {
      log("❌ Unexpected Error: $e", stackTrace: stackTrace);
      throw 'An unexpected error occurred: $e';
    }
  }

  // --- Login ---
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      log("✅ User Logged In");
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Login failed. Please try again.';
    }
  }

  // --- Logout ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  // --- Error Handler Helper ---
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'This email is already registered.';
      case 'invalid-email': return 'Invalid email address.';
      case 'weak-password': return 'Password is too weak.';
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      default: return e.message ?? 'Authentication failed.';
    }
  }
}
