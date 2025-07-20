// lib/src/features/student_dashboard/widgets/student_announcement_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Import provider từ feature của TA vì chúng ta dùng chung
import '../../ta_dashboard/providers/class_providers.dart';

class StudentAnnouncementTab extends ConsumerWidget {
  final String classId;
  const StudentAnnouncementTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe stream thông báo, logic này giống hệt bên TA
    final announcementsAsync = ref.watch(announcementsProvider(classId));

    // Dùng Scaffold để có nền trắng và các thuộc tính mặc định,
    // nhưng KHÔNG có FloatingActionButton.
    return Scaffold(
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(child: Text('Chưa có thông báo nào.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng bởi ${announcement.taName} • ${DateFormat.yMd().add_jm().format(announcement.createdAt.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 20),
                      Text(announcement.content),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}