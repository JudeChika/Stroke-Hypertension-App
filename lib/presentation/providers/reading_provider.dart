import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reading_model.dart';
import '../../data/repositories/reading_repository.dart';
import 'auth_provider.dart'; // Import auth_provider to check login state

final readingsProvider = StreamProvider.autoDispose<List<ReadingModel>>((ref) {
  // 1. Watch the auth state. If user is null (logged out), return empty stream.
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]); // Safe fallback: Return empty list
      }
      // 2. Only if user exists, fetch the readings
      final repo = ref.read(readingRepositoryProvider);
      return repo.readingsStream(limit: 20);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});