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

  // --- Sign Up with Enhanced Error Handling & Timeout ---
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      log("🔄 Attempting to create user: $email");

      // Add timeout to prevent infinite hanging
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          log("⏱️ Firebase Auth timeout after 30 seconds");
          throw 'Connection timeout. Please check your internet and try again.';
        },
      );

      log("✅ Auth User Created: ${result.user!.uid}");

      // Create User Document in Firestore with timeout
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        fullName: fullName,
      );

      log("🔄 Saving user to Firestore...");

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap())
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          log("⏱️ Firestore write timeout");
          throw 'Failed to save user data. Please try logging in.';
        },
      );

      log("✅ User Saved to Firestore: ${result.user!.uid}");

    } on FirebaseAuthException catch (e) {
      log("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      throw _handleAuthError(e);
    } on FirebaseException catch (e) {
      log("❌ FirebaseException (Firestore): ${e.code} - ${e.message}");
      throw 'Database error: ${e.message ?? "Failed to save user data"}';
    } catch (e, stackTrace) {
      log("❌ Unexpected Error: $e", stackTrace: stackTrace);

      // If it's our custom timeout message, rethrow it
      if (e is String) rethrow;

      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // --- Login with Timeout ---
  Future<void> login({required String email, required String password}) async {
    try {
      log("🔄 Attempting login for: $email");

      await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          log("⏱️ Login timeout after 30 seconds");
          throw 'Connection timeout. Please check your internet and try again.';
        },
      );

      log("✅ User Logged In: ${_auth.currentUser?.uid}");
    } on FirebaseAuthException catch (e) {
      log("❌ Login FirebaseAuthException: ${e.code} - ${e.message}");
      throw _handleAuthError(e);
    } catch (e) {
      log("❌ Login Error: $e");
      if (e is String) rethrow;
      throw 'Login failed. Please try again.';
    }
  }

  // --- Logout ---
  Future<void> logout() async {
    try {
      await _auth.signOut();
      log("✅ User Logged Out");
    } catch (e) {
      log("❌ Logout Error: $e");
      throw 'Logout failed. Please try again.';
    }
  }

  // --- Enhanced Error Handler ---
  String _handleAuthError(FirebaseAuthException e) {
    log("🔍 Handling Auth Error Code: ${e.code}");

    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}