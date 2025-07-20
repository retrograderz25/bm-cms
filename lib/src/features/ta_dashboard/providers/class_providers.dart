// lib/src/features/ta_dashboard/providers/class_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/enrollment_model.dart'; // THÊM IMPORT NÀY
import '../../../data/repositories/class_repository.dart';

// --- PROVIDER CŨ (ĐÃ CÓ) ---
final classRepositoryProvider = Provider<ClassRepository>((ref) {
  return ClassRepository(FirebaseFirestore.instance);
});

final taClassesProvider = StreamProvider.family<List<ClassModel>, String>((ref, taId) {
  final classRepository = ref.watch(classRepositoryProvider);
  return classRepository.getClassesForTA(taId);
});

// --- PROVIDER MỚI CẦN THÊM ---

// Provider để lấy danh sách học sinh trong một lớp cụ thể
final studentListProvider = StreamProvider.family<List<EnrollmentModel>, String>((ref, classId) {
  final classRepository = ref.watch(classRepositoryProvider);
  return classRepository.getStudentsInClass(classId);
});