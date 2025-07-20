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
      // Ném lại lỗi để UI xử lý
      rethrow;
    }
  }

  // Đăng ký tài khoản mới
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role, // Nhận vào một Enum thay vì String
  }) async {
    try {
      // 1. Tạo người dùng trong Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật tên hiển thị trong Firebase Auth (tùy chọn nhưng nên có)
      await userCredential.user?.updateDisplayName(displayName);

      // 2. Tạo đối tượng UserModel mới
      final user = userCredential.user;
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: displayName,
          role: role,
          createdAt: Timestamp.now(),
        );

        // 3. Lưu đối tượng UserModel vào Firestore collection 'users'
        // Document ID chính là uid của người dùng
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toFirestore());
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}