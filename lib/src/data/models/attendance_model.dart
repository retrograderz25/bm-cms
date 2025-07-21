// lib/src/data/models/attendance_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Import để dùng Color

// Enum cho Trạng thái Điểm danh, đã được mở rộng
enum AttendanceStatus {
  present,  // Có mặt
  late,     // Đi muộn
  absent,   // Vắng mặt
  cross,    // Chéo ca
  trial,    // Học thử
  other;    // Tình huống khác

  // Hàm để chuyển đổi từ chuỗi trong Firestore thành Enum
  static AttendanceStatus fromString(String? status) {
    if (status == null) return AttendanceStatus.other;
    return values.firstWhere(
          (e) => e.name == status,
      orElse: () => AttendanceStatus.other, // Mặc định là 'other' nếu có lỗi
    );
  }

  // Getter để hiển thị tên trạng thái thân thiện với người dùng
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Có mặt';
      case AttendanceStatus.late:
        return 'Đi muộn';
      case AttendanceStatus.absent:
        return 'Vắng mặt';
      case AttendanceStatus.cross:
        return 'Chéo ca';
      case AttendanceStatus.trial:
        return 'Học thử';
      case AttendanceStatus.other:
        return 'Khác';
    }
  }

  // Getter để lấy màu sắc tương ứng với mỗi trạng thái, rất hữu ích cho UI
  Color get displayColor {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.cross:
        return Colors.blue;
      case AttendanceStatus.trial:
        return Colors.purple;
      case AttendanceStatus.other:
        return Colors.grey;
    }
  }
}

class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName; // Tên học sinh để hiển thị nhanh
  final Timestamp checkInTime;
  final AttendanceStatus status;
  final String? note; // TRƯỜNG MỚI: Ghi chú cho lý do 'Khác' hoặc lý do vắng

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.checkInTime,
    required this.status,
    this.note,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AttendanceModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      checkInTime: data['checkInTime'] ?? Timestamp.now(),
      status: AttendanceStatus.fromString(data['status']),
      note: data['note'], // Đọc ghi chú từ Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'checkInTime': checkInTime,
      'status': status.name,
      'note': note, // Lưu ghi chú vào Firestore
    };
  }
}