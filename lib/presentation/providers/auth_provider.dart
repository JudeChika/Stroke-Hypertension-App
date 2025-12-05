import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider exposing the FirebaseAuth user. UI can watch this to know
/// whether someone is signed in. FirebaseAuth persists state on mobile by default.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});