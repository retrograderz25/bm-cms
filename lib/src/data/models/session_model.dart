// lib/src/data/models/session_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus {
  scheduled, // Đã lên lịch
  ongoing,   // Đang diễn ra
  completed; // Đã kết thúc

  static SessionStatus fromString(String status) => values.firstWhere((e) => e.name == status, orElse: () => scheduled);
}

class SessionModel {
  final String id;
  final String classId; // Lịch học thuộc lớp nào
  final String className; // Tên lớp để hiển thị nhanh
  final Timestamp sessionDate;
  final String taId;
  final String? notes;
  final SessionStatus status;

  SessionModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.sessionDate,
    required this.taId,
    this.notes,
    required this.status,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SessionModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      className: data['className'] ?? '',
      sessionDate: data['sessionDate'] ?? Timestamp.now(),
      taId: data['taId'] ?? '',
      notes: data['notes'],
      status: SessionStatus.fromString(data['status'] ?? 'scheduled'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classId': classId,
      'className': className,
      'sessionDate': sessionDate,
      'taId': taId,
      'notes': notes,
      'status': status.name,
    };
  }
}