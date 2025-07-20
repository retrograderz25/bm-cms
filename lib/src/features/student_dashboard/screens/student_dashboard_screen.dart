// lib/src/features/student_dashboard/screens/student_dashboard_screen.dart

import 'package:bm_cms/src/features/student_dashboard/screens/student_class_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_providers.dart';
import '../providers/student_providers.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.asData?.value;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final classesAsyncValue = ref.watch(studentClassesProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser.displayName ?? 'Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          )
        ],
      ),
      body: classesAsyncValue.when(
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('Bạn chưa được thêm vào lớp học nào.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final aClass = classes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(aClass.className, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(aClass.description),
                      const SizedBox(height: 4),
                      Text('Trợ giảng: ${aClass.taName}'),
                      Text('Lịch học: ${aClass.schedule}'),
                    ],
                  ),
                  onTap: () {
                    // TODO: Điều hướng đến trang chi tiết lớp học của học sinh
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentClassDetailScreen(classModel: aClass),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải lớp học: $err')),
      ),
    );
  }
}