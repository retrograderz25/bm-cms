// lib/src/features/student_dashboard/widgets/student_grade_list_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_providers.dart';
import '../../ta_dashboard/providers/learning_providers.dart';

class StudentGradeListTab extends ConsumerWidget {
  final String classId;
  const StudentGradeListTab({super.key, required this.classId});

  // HÀM MỚI: HIỂN THỊ DIALOG CHỨA NHẬN XÉT
  void _showFeedbackDialog(BuildContext context, String feedback) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhận xét của Trợ giảng'),
          content: SingleChildScrollView( // Dùng để có thể cuộn nếu nhận xét quá dài
            child: Text(feedback),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ref.watch(authStateChangesProvider).asData?.value?.uid;

    if (studentId == null) {
      return const Center(child: Text("Không thể xác định người dùng."));
    }

    final assignmentsAsync = ref.watch(assignmentsProvider(classId));
    final submissionsAsync = ref.watch(studentSubmissionsProvider((classId: classId, studentId: studentId)));

    return assignmentsAsync.when(
      data: (assignments) {
        return submissionsAsync.when(
          data: (submissions) {
            if (assignments.isEmpty) {
              return const Center(child: Text('Lớp học chưa có bài tập nào.'));
            }

            final submissionMap = {for (var s in submissions) s.assignmentId: s};

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: assignments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final submission = submissionMap[assignment.id];
                // Kiểm tra xem có nhận xét hay không
                final hasFeedback = submission?.feedback?.isNotEmpty ?? false;

                return Card(
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(assignment.description, maxLines: 1, overflow: TextOverflow.ellipsis),

                    // --- BẮT ĐẦU SỬA Ở ĐÂY ---
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Giúp Row co lại vừa với nội dung
                      children: [
                        // Widget hiển thị điểm
                        Text(
                          submission?.grade?.toString() ?? 'Chưa chấm',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: submission?.grade != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                          ),
                        ),
                        // Chỉ hiển thị icon nếu có nhận xét
                        if (hasFeedback)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.comment_outlined),
                              tooltip: 'Xem nhận xét',
                              onPressed: () {
                                _showFeedbackDialog(context, submission!.feedback!);
                              },
                            ),
                          ),
                      ],
                    ),
                    // --- KẾT THÚC SỬA Ở ĐÂY ---
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