// lib/src/features/ta_dashboard/providers/learning_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/submission_model.dart';
import '../../../data/repositories/learning_repository.dart';

// Provider để cung cấp một instance của LearningRepository
final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(FirebaseFirestore.instance);
});


// --- PROVIDERS CHO TRỢ GIẢNG (TA) ---

/// Provider để lấy danh sách BTVN của một lớp học.
/// [family] nhận vào `classId`.
final assignmentsProvider = StreamProvider.family<List<AssignmentModel>, String>((ref, classId) {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getAssignments(classId);
});

/// Provider để lấy một bản ghi điểm duy nhất.
/// Dùng trong màn hình chấm điểm của TA.
/// [family] nhận vào một record chứa `assignmentId` và `studentId`.
final singleSubmissionProvider = StreamProvider.family<SubmissionModel?, ({String assignmentId, String studentId})>((ref, ids) {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getSingleSubmission(ids.assignmentId, ids.studentId);
});


// --- PROVIDERS CHO HỌC SINH (STUDENT) ---

/// Provider để lấy tất cả các bản ghi điểm của một học sinh trong một lớp.
/// Dùng để hiển thị bảng điểm cho học sinh.
/// [family] nhận vào một record chứa `classId` và `studentId`.
final studentSubmissionsProvider = StreamProvider.family<List<SubmissionModel>, ({String classId, String studentId})>((ref, ids) {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getSubmissionsForStudent(ids.classId, ids.studentId);
});