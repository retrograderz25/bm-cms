// lib/src/features/admin/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // THÊM IMPORT NÀY
import '../../authentication/providers/auth_providers.dart'; // THÊM IMPORT NÀY
import '../widgets/user_management_tab.dart';

// THAY ĐỔI: Chuyển thành ConsumerWidget để có thể dùng `ref`
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  // THAY ĐỔI: Thêm WidgetRef ref vào hàm build
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          // THÊM NÚT ĐĂNG XUẤT VÀO ĐÂY
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: () async {
                // Gọi hàm signOut từ AuthRepository
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.class_), text: 'Tất cả Lớp học'),
              Tab(icon: Icon(Icons.people), text: 'Người dùng'),
              Tab(icon: Icon(Icons.analytics), text: 'Thống kê'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Danh sách tất cả các lớp học sẽ ở đây.')),
            UserManagementTab(),
            Center(child: Text('Các biểu đồ thống kê sẽ ở đây.')),
          ],
        ),
      ),
    );
  }
}