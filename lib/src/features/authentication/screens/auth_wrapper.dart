// lib/src/features/authentication/screens/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';
import '../../ta_dashboard/screens/ta_dashboard_screen.dart';
import '../../student_dashboard/screens/student_dashboard_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // Nếu đã đăng nhập, lắng nghe thông tin user từ Firestore
          final userData = ref.watch(userDataProvider(user.uid));
          return userData.when(
            data: (userModel) {
              if (userModel != null) {
                // Dựa vào vai trò để điều hướng
                switch (userModel.role) {
                  case UserRole.ta:
                    return const TaDashboardScreen();
                  case UserRole.student:
                    return const StudentDashboardScreen();
                  case UserRole.unknown:
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Vai trò của bạn không hợp lệ."),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => ref.read(authRepositoryProvider).signOut(),
                              child: const Text('Đăng xuất'),
                            )
                          ],
                        ),
                      ),
                    );
                }
              }
              // Trường hợp user tồn tại trong Auth nhưng không có trong Firestore
              // Có thể xảy ra nếu việc ghi vào Firestore bị lỗi sau khi tạo user Auth
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Lỗi: Không tìm thấy dữ liệu người dùng."),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => ref.read(authRepositoryProvider).signOut(),
                        child: const Text('Đăng xuất'),
                      )
                    ],
                  ),
                ),
              );
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi tải dữ liệu người dùng: $err'))),
          );
        } else {
          // Nếu chưa đăng nhập, hiển thị màn hình Login
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Đã có lỗi xảy ra: $err'))),
    );
  }
}