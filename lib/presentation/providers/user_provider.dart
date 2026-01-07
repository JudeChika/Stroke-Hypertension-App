import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart'; // Import auth_provider

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userStreamProvider = StreamProvider<UserModel?>((ref) {
  // 1. Watch auth state to prevent crashes on logout
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null); // Safe fallback
      }
      final repo = ref.read(userRepositoryProvider);
      return repo.userStream();
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});