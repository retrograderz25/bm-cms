// lib/src/features/admin/providers/admin_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../authentication/providers/auth_providers.dart';// Dùng chung authRepositoryProvider

// Provider để lấy danh sách tất cả người dùng
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getAllUsers();
});