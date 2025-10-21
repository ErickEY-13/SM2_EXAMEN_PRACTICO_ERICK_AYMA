import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/login_history.dart';
import '../../infrastructure/login_history_repository.dart';

final loginHistoryRepositoryProvider = Provider<LoginHistoryRepository>((ref) {
  return LoginHistoryRepository();
});

final loginHistoryStreamProvider = StreamProvider.family<List<LoginHistory>, String>((ref, userId) {
  final repository = ref.watch(loginHistoryRepositoryProvider);
  return repository.getLoginHistory(userId);
});