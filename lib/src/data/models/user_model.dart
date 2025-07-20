// lib/src/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum để định nghĩa các vai trò một cách an toàn, tránh gõ sai chuỗi 'student' hay 'ta'
enum UserRole {
  student,
  ta,
  unknown; // Vai trò mặc định nếu có lỗi

  // Chuyển đổi từ chuỗi trong Firestore thành Enum
  static UserRole fromString(String role) {
    switch (role) {
      case 'student':
        return UserRole.student;
      case 'ta':
        return UserRole.ta;
      default:
        return UserRole.unknown;
    }
  }

  // Chuyển đổi từ Enum thành chuỗi để lưu vào Firestore
  String get name => toString().split('.').last;
}


class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role; // Sử dụng Enum để an toàn hơn
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  // Factory constructor để tạo UserModel từ một Firestore document
  // DocumentSnapshot là dữ liệu thô đọc từ Firestore
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for UserModel ID: ${doc.id}');
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Người dùng mới',
      photoUrl: data['photoUrl'],
      // Sử dụng UserRole.fromString để chuyển đổi an toàn
      role: UserRole.fromString(data['role'] ?? 'unknown'),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Phương thức để chuyển đổi đối tượng UserModel thành một Map
  // Map này sẽ được dùng để ghi dữ liệu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid, // Lưu uid cả trong document để dễ truy vấn nếu cần
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name, // Sử dụng .name để lấy chuỗi 'student' hoặc 'ta'
      'createdAt': createdAt,
    };
  }
}