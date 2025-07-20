// lib/src/features/ta_dashboard/screens/grading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/submission_model.dart';
import '../providers/class_providers.dart';
import '../providers/learning_providers.dart';

// --- GradingScreen widget không có thay đổi ---
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
            padding: const EdgeInsets.all(16.0),
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


// --- _GradingCard widget đã được cập nhật hoàn chỉnh ---
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

  // Hàm hiển thị dialog cho nhận xét
  void _showFeedbackDialog(BuildContext context, WidgetRef ref, SubmissionModel? currentSubmission) {
    final feedbackController = TextEditingController(text: currentSubmission?.feedback ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(currentSubmission?.feedback?.isNotEmpty ?? false ? 'Sửa nhận xét' : 'Thêm nhận xét mới'),
          content: TextFormField(
            controller: feedbackController,
            decoration: const InputDecoration(
              labelText: 'Nhập nhận xét',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveData(
                    ref,
                    currentSubmission?.id,
                    feedback: feedbackController.text.trim()
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Hàm chung để lưu cả điểm và nhận xét
  Future<void> _saveData(WidgetRef ref, String? existingSubmissionId, {String? feedback}) async {
    final grade = double.tryParse(_gradeController.text);

    if (grade == null) {
      SnackbarHelper.showError(context, message: 'Vui lòng nhập điểm hợp lệ.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final currentFeedback = feedback ?? ref.read(singleSubmissionProvider((
      assignmentId: widget.assignment.id,
      studentId: widget.student.studentId
      ))).value?.feedback;

      await ref.read(learningRepositoryProvider).gradeSubmission(
        classId: widget.assignment.classId,
        assignmentId: widget.assignment.id,
        studentId: widget.student.studentId,
        grade: grade,
        feedback: currentFeedback,
        existingSubmissionId: existingSubmissionId,
      );
      if (mounted) {
        SnackbarHelper.showSuccess(context, message: 'Đã lưu thành công!');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, message: 'Lỗi khi lưu: $e');
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionAsync = ref.watch(singleSubmissionProvider(
      (assignmentId: widget.assignment.id, studentId: widget.student.studentId),
    ));

    ref.listen(
      singleSubmissionProvider((assignmentId: widget.assignment.id, studentId: widget.student.studentId)),
          (_, next) {
        final grade = next.asData?.value?.grade;
        if (grade != null && _gradeController.text != grade.toString()) {
          _gradeController.text = grade.toString();
        } else if (grade == null && _gradeController.text.isNotEmpty) {
          _gradeController.clear();
        }
      },
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.student.studentName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(widget.student.studentEmail, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                // --- SỬA LẠI LOGIC HIỂN THỊ Ở ĐÂY ---
                submissionAsync.when(
                  data: (submission) {
                    final hasFeedback = submission?.feedback?.isNotEmpty ?? false;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Chỉ hiển thị icon xem/sửa khi đã có nhận xét
                        if (hasFeedback)
                          IconButton(
                            icon: Icon(Icons.comment, color: Theme.of(context).colorScheme.primary),
                            tooltip: 'Xem/Sửa nhận xét',
                            onPressed: () {
                              _showFeedbackDialog(context, ref, submission);
                            },
                          ),
                        SizedBox(width: 8,),
                        // Chip điểm luôn hiển thị
                        Chip(
                          label: Text(
                            submission?.grade?.toString() ?? 'Chưa chấm',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          backgroundColor: submission?.grade != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (e, s) => const Icon(Icons.error_outline, color: Colors.red),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập/Sửa điểm',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                ),
                const SizedBox(width: 8),
                // Icon này dùng để "Thêm mới" nhận xét khi chưa có
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Thêm nhận xét mới',
                  onPressed: () {
                    final currentSubmission = submissionAsync.asData?.value;
                    _showFeedbackDialog(context, ref, currentSubmission);
                  },
                ),
                const SizedBox(width: 8),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    final existingSubmissionId = submissionAsync.asData?.value?.id;
                    _saveData(ref, existingSubmissionId);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}