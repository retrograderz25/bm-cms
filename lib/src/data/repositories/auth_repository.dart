// lib/src/data/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  // Lấy trạng thái đăng nhập hiện tại
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy thông tin người dùng từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Đăng nhập bằng Email và Password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // --- HÀM SIGNUP ĐƯỢC CẬP NHẬT ---
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    // Thêm các tham số tùy chọn cho học sinh
    StudentStatus? status,
    String? gradeLevel,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);

      final user = userCredential.user;
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: displayName,
          role: role,
          createdAt: Timestamp.now(),
          // Gán các giá trị mới
          status: status,
          gradeLevel: gradeLevel,
        );

        await _firestore.collection('users').doc(newUser.uid).set(newUser.toFirestore());
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // --- CÁC PHƯƠNG THỨC MỚI CHO ADMIN ---

  // Lấy danh sách tất cả người dùng trong hệ thống.
  // Sử dụng Stream để tự động cập nhật.

  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Cập nhật thông tin của một người dùng.
  /// Dùng bởi Admin.

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa document của một người dùng trong Firestore.
  /// Chỉ Admin mới có quyền thực hiện.
  Future<void> deleteUserDoc(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}