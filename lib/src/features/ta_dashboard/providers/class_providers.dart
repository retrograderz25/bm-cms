// lib/src/features/ta_dashboard/providers/class_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/class_model.dart';
import '../../../data/repositories/class_repository.dart';

// 1. Provider để cung cấp một instance của ClassRepository
final classRepositoryProvider = Provider<ClassRepository>((ref) {
  // Lấy instance của Firestore đã được cung cấp ở tầng Auth
  return ClassRepository(FirebaseFirestore.instance);
});

// 2. Provider để cung cấp Stream danh sách lớp học của một TA
// Sử dụng StreamProvider vì dữ liệu cần cập nhật real-time
// Sử dụng .family để có thể truyền vào một tham số (taId)
final taClassesProvider = StreamProvider.family<List<ClassModel>, String>((ref, taId) {
  // Lấy repository từ provider ở trên
  final classRepository = ref.watch(classRepositoryProvider);
  // Gọi phương thức để lấy stream
  return classRepository.getClassesForTA(taId);
});