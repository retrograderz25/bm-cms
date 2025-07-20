// lib/src/features/student_dashboard/providers/student_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/class_model.dart';
// Dùng chung ClassRepository, nên có thể import provider của nó
import '../../ta_dashboard/providers/class_providers.dart';

// Provider để lấy danh sách các lớp học của một học sinh
final studentClassesProvider = StreamProvider.family<List<ClassModel>, String>((ref, studentId) {
  final classRepository = ref.watch(classRepositoryProvider);
  return classRepository.getClassesForStudent(studentId);
});