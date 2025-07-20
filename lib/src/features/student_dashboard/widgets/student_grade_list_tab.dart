// lib/src/features/student_dashboard/widgets/student_grade_list_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_providers.dart';
import '../../ta_dashboard/providers/learning_providers.dart'; // Dùng chung provider

class StudentGradeListTab extends ConsumerWidget {
  final String classId;
  const StudentGradeListTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy ID của học sinh đang đăng nhập
    final studentId = ref.watch(authStateChangesProvider).asData?.value?.uid;

    if (studentId == null) {
      return const Center(child: Text("Không thể xác định người dùng."));
    }

    // Lấy danh sách tất cả BTVN của lớp để biết tên bài tập
    final assignmentsAsync = ref.watch(assignmentsProvider(classId));
    // Lấy danh sách tất cả điểm của học sinh này
    final submissionsAsync = ref.watch(studentSubmissionsProvider((classId: classId, studentId: studentId)));

    return assignmentsAsync.when(
      data: (assignments) {
        return submissionsAsync.when(
          data: (submissions) {
            if (assignments.isEmpty) {
              return const Center(child: Text('Lớp học chưa có bài tập nào.'));
            }

            // Tạo một Map để dễ dàng truy cập điểm bằng assignmentId
            final submissionMap = {for (var s in submissions) s.assignmentId: s};

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final submission = submissionMap[assignment.id];

                return Card(
                  child: ListTile(
                    title: Text(assignment.title),
                    subtitle: Text(assignment.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      submission?.grade?.toString() ?? 'Chưa có điểm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: submission?.grade != null ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi tải điểm: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi tải BTVN: $err')),
    );
  }
}