// lib/src/data/repositories/learning_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';

class LearningRepository {
  final FirebaseFirestore _firestore;

  LearningRepository(this._firestore);

  // --- CÁC PHƯƠNG THỨC LIÊN QUAN ĐẾN BTVN (ASSIGNMENTS) ---

  /// Lấy danh sách tất cả BTVN của một lớp học.
  /// Sắp xếp theo ngày học giảm dần (buổi học mới nhất lên đầu).
  Stream<List<AssignmentModel>> getAssignments(String classId) {
    return _firestore
        .collection('assignments')
        .where('classId', isEqualTo: classId)
        .orderBy('sessionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList());
  }

  /// Tạo một mục BTVN mới cho lớp học.
  Future<void> createAssignment(AssignmentModel assignment) async {
    await _firestore.collection('assignments').add(assignment.toFirestore());
  }

  // --- CÁC PHƯƠNG THỨC LIÊN QUAN ĐẾN NỘP BÀI/ĐIỂM SỐ (SUBMISSIONS) ---

  /// Lấy tất cả các bài nộp/điểm của một học sinh trong một lớp.
  /// Dùng để hiển thị bảng điểm tổng quát cho học sinh.
  Stream<List<SubmissionModel>> getSubmissionsForStudent(String classId, String studentId) {
    return _firestore
        .collection('submissions')
        .where('classId', isEqualTo: classId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SubmissionModel.fromFirestore(doc))
        .toList());
  }

  /// Lấy một bản ghi nộp bài/điểm duy nhất của một học sinh cho một BTVN cụ thể.
  /// Dùng trong màn hình chấm điểm để hiển thị điểm đã có.
  Stream<SubmissionModel?> getSingleSubmission(String assignmentId, String studentId) {
    return _firestore
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null; // Trả về null nếu chưa có submission
      }
      return SubmissionModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// Tạo mới hoặc cập nhật điểm/nhận xét cho một học sinh.
  /// Nếu `existingSubmissionId` được cung cấp, nó sẽ cập nhật.
  /// Nếu không, nó sẽ tạo một document mới.
  Future<void> gradeSubmission({
    required String classId,
    required String assignmentId,
    required String studentId,
    required double grade,
    String? feedback,
    String? existingSubmissionId,
  }) async {
    final submission = SubmissionModel(
      id: existingSubmissionId ?? '', // Dùng ID cũ nếu có
      assignmentId: assignmentId,
      studentId: studentId,
      classId: classId,
      grade: grade,
      status: SubmissionStatus.graded, // Chuyển trạng thái thành đã chấm
      feedback: feedback,
    );

    if (existingSubmissionId != null && existingSubmissionId.isNotEmpty) {
      // Cập nhật submission đã có
      await _firestore.collection('submissions').doc(existingSubmissionId).set(submission.toFirestore());
    } else {
      // Tạo submission mới
      await _firestore.collection('submissions').add(submission.toFirestore());
    }
  }

  /// Lấy tất cả các submissions (điểm) cho một bài tập cụ thể.
  Stream<List<SubmissionModel>> getSubmissionsForAssignment(String assignmentId) {
    return _firestore
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SubmissionModel.fromFirestore(doc))
        .toList());
  }

}