// lib/src/features/ta_dashboard/screens/grading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../providers/class_providers.dart';
import '../providers/learning_providers.dart';

class GradingScreen extends ConsumerWidget {
  final String classId;
  final AssignmentModel assignment;

  const GradingScreen({
    super.key,
    required this.classId,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentListAsync = ref.watch(studentListProvider(classId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chấm điểm: ${assignment.title}'),
      ),
      body: studentListAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Lớp học này chưa có học sinh nào.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _GradingCard(
                student: student,
                assignment: assignment,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải danh sách học sinh: $err')),
      ),
    );
  }
}

// Chuyển thành ConsumerStatefulWidget để quản lý controller và state loading
class _GradingCard extends ConsumerStatefulWidget {
  final EnrollmentModel student;
  final AssignmentModel assignment;

  const _GradingCard({required this.student, required this.assignment});

  @override
  ConsumerState<_GradingCard> createState() => __GradingCardState();
}

class __GradingCardState extends ConsumerState<_GradingCard> {
  final _gradeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _saveGrade(WidgetRef ref, String? existingSubmissionId) async {
    final grade = double.tryParse(_gradeController.text);
    if (grade == null) {
      SnackbarHelper.showError(context, message: 'Điểm không hợp lệ.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await ref.read(learningRepositoryProvider).gradeSubmission(
        classId: widget.assignment.classId,
        assignmentId: widget.assignment.id,
        studentId: widget.student.studentId,
        grade: grade,
        existingSubmissionId: existingSubmissionId,
      );
      if (mounted) {
        SnackbarHelper.showSuccess(context, message: 'Đã lưu điểm cho ${widget.student.studentName}');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, message: 'Lỗi khi lưu điểm: $e');
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe submission hiện tại của học sinh này
    final submissionAsync = ref.watch(singleSubmissionProvider(
      (
      assignmentId: widget.assignment.id,
      studentId: widget.student.studentId,
      ),
    ));

    // Dùng `ref.listen` để cập nhật controller một cách an toàn, chỉ khi dữ liệu thay đổi
    // và không gây rebuild không cần thiết.
    ref.listen(singleSubmissionProvider(
        (assignmentId: widget.assignment.id, studentId: widget.student.studentId)),
            (_, next) {
          final grade = next.asData?.value?.grade;
          // Chỉ cập nhật text nếu nó khác với giá trị hiện tại để tránh vòng lặp vô hạn
          if (grade != null && _gradeController.text != grade.toString()) {
            _gradeController.text = grade.toString();
          }
        });

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.student.studentName, style: Theme.of(context).textTheme.titleLarge),
            Text(widget.student.studentEmail, style: Theme.of(context).textTheme.bodySmall),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Điểm',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                ),
                const SizedBox(width: 16),
                // Hiển thị loading hoặc nút lưu
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    // Lấy submission ID hiện tại từ submissionAsync đã watch ở trên
                    final existingSubmissionId = submissionAsync.asData?.value?.id;
                    _saveGrade(ref, existingSubmissionId);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}