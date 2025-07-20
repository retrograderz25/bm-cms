// lib/src/data/models/announcement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String classId;
  final String title;
  final String content;
  final String taName; // Tên người đăng để hiển thị
  final Timestamp createdAt;

  AnnouncementModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.content,
    required this.taName,
    required this.createdAt,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AnnouncementModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      taName: data['taName'] ?? 'N/A',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classId': classId,
      'title': title,
      'content': content,
      'taName': taName,
      'createdAt': createdAt,
    };
  }
}