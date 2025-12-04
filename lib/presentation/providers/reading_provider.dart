import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reading_model.dart';
import '../../data/repositories/reading_repository.dart';

// Streams the latest readings for the current user.
// UI can watch this provider to rebuild automatically when Firestore changes.
final readingsProvider = StreamProvider.autoDispose<List<ReadingModel>>((ref) {
  final repo = ref.read(readingRepositoryProvider);
  return repo.readingsStream(limit: 20);
});