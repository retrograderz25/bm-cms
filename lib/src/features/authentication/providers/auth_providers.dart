// lib/src/features/authentication/providers/auth_providers.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

// 1. Provider cho các instance của Firebase
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// 2. Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});

// 3. Provider để theo dõi trạng thái thay đổi của Auth (đăng nhập/đăng xuất)
// Đây là provider quan trọng nhất, nó sẽ cho app biết user hiện tại là ai.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// 4. Provider để lấy dữ liệu UserModel từ Firestore dựa trên UID
final userDataProvider = FutureProvider.family<UserModel?, String>((ref, uid) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getUserData(uid);
});