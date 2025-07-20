// lib/src/data/models/class_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id; // ID của document trên Firestore
  final String className;
  final String description;
  final String taId; // ID của người tạo lớp (tham chiếu tới users.uid)
  final String taName; // Tên người tạo, để hiển thị nhanh
  final String schedule;
  final Timestamp createdAt;

  ClassModel({
    required this.id,
    required this.className,
    required this.description,
    required this.taId,
    required this.taName,
    required this.schedule,
    required this.createdAt,
  });

  // Factory constructor để tạo ClassModel từ dữ liệu Firestore
  factory ClassModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ClassModel(
      id: doc.id,
      className: data['className'] ?? '',
      description: data['description'] ?? '',
      taId: data['taId'] ?? '',
      taName: data['taName'] ?? '',
      schedule: data['schedule'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Phương thức để chuyển đổi đối tượng ClassModel thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'className': className,
      'description': description,
      'taId': taId,
      'taName': taName,
      'schedule': schedule,
      'createdAt': createdAt,
    };
  }
}