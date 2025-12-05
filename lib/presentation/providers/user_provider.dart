import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

// Provide a repository instance (used by other parts of the app)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Stream provider exposing the signed-in user's Firestore document as a UserModel
final userStreamProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return repo.userStream();
});