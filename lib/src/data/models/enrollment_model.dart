// lib/src/data/models/enrollment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id; // ID của document enrollment
  final String studentId;
  final String classId;
  final String studentName; // Để hiển thị nhanh
  final String studentEmail; // Để hiển thị nhanh
  final Timestamp joinDate;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.studentName,
    required this.studentEmail,
    required this.joinDate,
  });

  factory EnrollmentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EnrollmentModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      studentName: data['studentName'] ?? 'N/A',
      studentEmail: data['studentEmail'] ?? 'N/A',
      joinDate: data['joinDate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'classId': classId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'joinDate': joinDate,
    };
  }
}