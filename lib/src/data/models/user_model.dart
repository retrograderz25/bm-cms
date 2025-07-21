// lib/src/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum cho Vai trò
enum UserRole {
  student,
  ta,
  admin,
  unknown;

  static UserRole fromString(String role) => values.firstWhere((e) => e.name == role, orElse: () => unknown);
}

// Enum MỚI cho Trạng thái Học sinh
enum StudentStatus {
  active,   // Đang học chính thức
  trial,    // Đang học thử
  inactive; // Đã nghỉ

  static StudentStatus fromString(String status) => values.firstWhere((e) => e.name == status, orElse: () => inactive);
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final Timestamp createdAt;

  // --- CÁC TRƯỜNG MỚI ---
  final StudentStatus? status; // Dành cho học sinh, có thể null cho TA
  final String? gradeLevel;   // Khối/Cấp độ, VD: "12", "IELTS 6.5"

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.status,
    this.gradeLevel,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Người dùng mới',
      photoUrl: data['photoUrl'],
      role: UserRole.fromString(data['role'] ?? 'unknown'),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] != null ? StudentStatus.fromString(data['status']) : null,
      gradeLevel: data['gradeLevel'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'createdAt': createdAt,
      'status': status?.name, // Chỉ lưu nếu không null
      'gradeLevel': gradeLevel,
    };
  }
}