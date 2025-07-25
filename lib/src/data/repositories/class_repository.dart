// lib/src/data/repositories/class_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';
import '../models/class_model.dart';
import '../models/enrollment_model.dart';
import '../models/user_model.dart';

class ClassRepository {
  final FirebaseFirestore _firestore;

  ClassRepository(this._firestore);

  // --- PHƯƠNG THỨC CŨ (ĐÃ CÓ) ---
  Stream<List<ClassModel>> getClassesForTA(String taId) {
    return _firestore
        .collection('classes')
        .where('taId', isEqualTo: taId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createClass(ClassModel newClass) async {
    try {
      await _firestore.collection('classes').add(newClass.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // --- CÁC PHƯƠNG THỨC MỚI CẦN THÊM ---

  // Lấy danh sách học sinh trong một lớp
  Stream<List<EnrollmentModel>> getStudentsInClass(String classId) {
    return _firestore
        .collection('enrollments')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EnrollmentModel.fromFirestore(doc))
        .toList());
  }

  // Thêm học sinh vào lớp bằng email
  Future<void> addStudentToClass({
    required String studentEmail,
    required String classId,
  }) async {
    // 1. Tìm user có email tương ứng và có vai trò là student
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: studentEmail)
        .where('role', isEqualTo: 'student') // Chỉ thêm được học sinh
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('Không tìm thấy học sinh với email này.');
    }

    final studentDoc = userQuery.docs.first;
    final student = UserModel.fromFirestore(studentDoc);

    // 2. Kiểm tra xem học sinh đã ở trong lớp chưa
    final existingEnrollment = await _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: student.uid)
        .where('classId', isEqualTo: classId)
        .limit(1)
        .get();

    if (existingEnrollment.docs.isNotEmpty) {
      throw Exception('Học sinh này đã ở trong lớp.');
    }

    // 3. Tạo bản ghi enrollment mới
    final newEnrollment = EnrollmentModel(
      id: '', // Sẽ được tạo tự động
      studentId: student.uid,
      classId: classId,
      studentName: student.displayName,
      studentEmail: student.email,
      joinDate: Timestamp.now(),
    );

    await _firestore.collection('enrollments').add(newEnrollment.toFirestore());
  }

  // Lấy danh sách lớp học mà một học sinh tham gia
  Stream<List<ClassModel>> getClassesForStudent(String studentId) {
    return _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .asyncMap((enrollmentSnapshot) async {
      if (enrollmentSnapshot.docs.isEmpty) {
        return [];
      }

      final classIds = enrollmentSnapshot.docs.map((doc) => doc.data()['classId'] as String).toList();

      if (classIds.isEmpty) {
        return [];
      }

      final classDocs = await _firestore
          .collection('classes')
          .where(FieldPath.documentId, whereIn: classIds)
          .get();

      return classDocs.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
    });
  }

  // --- CÁC PHƯƠNG THỨC MỚI CHO THÔNG BÁO ---

  /// Lấy danh sách thông báo của một lớp, sắp xếp mới nhất lên đầu.
  Stream<List<AnnouncementModel>> getAnnouncements(String classId) {
    return _firestore
        .collection('announcements')
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AnnouncementModel.fromFirestore(doc))
        .toList());
  }

  /// Tạo một thông báo mới.
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    await _firestore.collection('announcements').add(announcement.toFirestore());
  }

  /// Cập nhật thông tin của một lớp học.
  Future<void> updateClass(ClassModel updatedClass) async {
    try {
      await _firestore
          .collection('classes')
          .doc(updatedClass.id)
          .update(updatedClass.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa một lớp học.
  /// Lưu ý: Thao tác này hiện tại chỉ xóa document của lớp.
  /// Để xóa tất cả dữ liệu liên quan (học sinh, BTVN, điểm), cần dùng Cloud Functions.
  Future<void> deleteClass(String classId) async {
    try {
      await _firestore.collection('classes').doc(classId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật một thông báo đã có.
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection('announcements')
          .doc(announcement.id)
          .update(announcement.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa một thông báo.
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).delete();
    } catch (e) {
      rethrow;
    }
  }

}