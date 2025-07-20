// lib/src/data/models/submission_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { graded, pending, missing }

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String classId;
  final double? grade; // Điểm số, có thể null nếu chưa chấm
  final SubmissionStatus status; // Đã chấm, chờ chấm, còn nợ
  final String? feedback; // Nhận xét của TA

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.classId,
    this.grade,
    required this.status,
    this.feedback,
  });

  factory SubmissionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SubmissionModel(
      id: doc.id,
      assignmentId: data['assignmentId'] ?? '',
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      grade: (data['grade'] as num?)?.toDouble(),
      status: SubmissionStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => SubmissionStatus.missing,
      ),
      feedback: data['feedback'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'classId': classId,
      'grade': grade,
      'status': status.name,
      'feedback': feedback,
    };
  }
}