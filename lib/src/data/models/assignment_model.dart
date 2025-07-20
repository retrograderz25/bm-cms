// lib/src/data/models/assignment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String classId;
  final String title; // VD: "BTVN Buổi 3"
  final String description; // Mô tả chi tiết
  final Timestamp sessionDate; // Ngày của buổi học
  final Timestamp dueDate; // Hạn nộp
  final Timestamp createdAt;

  AssignmentModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.sessionDate,
    required this.dueDate,
    required this.createdAt,
  });

  factory AssignmentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AssignmentModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      sessionDate: data['sessionDate'] ?? Timestamp.now(),
      dueDate: data['dueDate'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classId': classId,
      'title': title,
      'description': description,
      'sessionDate': sessionDate,
      'dueDate': dueDate,
      'createdAt': createdAt,
    };
  }
}