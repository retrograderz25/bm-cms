// lib/src/common/utils/snackbar_helper.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SnackbarHelper {
  // Hàm hiển thị snackbar lỗi
  static void showError(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error, // Sử dụng màu lỗi từ theme
        behavior: SnackBarBehavior.floating, // Để snackbar nổi lên trên
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        duration: Duration(seconds: 30),
      ),
    );
  }

  // Hàm hiển thị snackbar thành công
  static void showSuccess(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600], // Màu xanh lá cây cho thành công
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        duration: Duration(seconds: 5),
      ),
    );
  }
}