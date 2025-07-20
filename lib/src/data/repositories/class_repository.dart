// lib/src/data/repositories/class_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

class ClassRepository {
  final FirebaseFirestore _firestore;

  ClassRepository(this._firestore);

  // Phương thức để LẤY danh sách lớp học của một TA cụ thể
  // Sử dụng Stream để dữ liệu tự động cập nhật trên UI khi có thay đổi trên Firestore
  Stream<List<ClassModel>> getClassesForTA(String taId) {
    return _firestore
        .collection('classes')
        .where('taId', isEqualTo: taId)
        .orderBy('createdAt', descending: true) // Sắp xếp lớp mới nhất lên đầu
        .snapshots() // Đây là một Stream
        .map((snapshot) {
      // Chuyển đổi mỗi document thành một đối tượng ClassModel
      return snapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
    });
  }

  // Phương thức để TẠO một lớp học mới
  Future<void> createClass(ClassModel newClass) async {
    try {
      // Firestore sẽ tự động tạo một ID cho document mới
      await _firestore.collection('classes').add(newClass.toFirestore());
    } catch (e) {
      print('Error creating class: $e');
      rethrow; // Ném lại lỗi để UI có thể bắt và hiển thị thông báo
    }
  }
}