// lib/src/features/ta_dashboard/widgets/assignment_list_tab.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/assignment_model.dart';
import '../providers/learning_providers.dart';
import '../screens/grading_screen.dart';

class AssignmentListTab extends ConsumerWidget {
  final String classId;
  const AssignmentListTab({super.key, required this.classId});

  // Hàm hiển thị dialog để tạo BTVN mới (Không có thay đổi trong logic)
  void _showCreateAssignmentDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? sessionDate;
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tạo Bài tập về nhà mới'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Tiêu đề (VD: BTVN Buổi 3)'),
                        validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Ngày học'),
                        subtitle: Text(sessionDate == null
                            ? 'Chưa chọn'
                            : DateFormat.yMd().format(sessionDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              sessionDate = pickedDate;
                            });
                          }
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hạn nộp'),
                        subtitle: Text(dueDate == null
                            ? 'Chưa chọn'
                            : DateFormat.yMd().format(dueDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: sessionDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              dueDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate() && sessionDate != null && dueDate != null) {
                      final newAssignment = AssignmentModel(
                        id: '',
                        classId: classId,
                        title: titleController.text,
                        description: descriptionController.text,
                        sessionDate: Timestamp.fromDate(sessionDate!),
                        dueDate: Timestamp.fromDate(dueDate!),
                        createdAt: Timestamp.now(),
                      );

                      try {
                        await ref.read(learningRepositoryProvider).createAssignment(newAssignment);
                        Navigator.pop(context);
                        SnackbarHelper.showSuccess(context, message: 'Tạo BTVN thành công!');
                      } catch (e) {
                        SnackbarHelper.showError(context, message: 'Lỗi: $e');
                      }
                    } else {
                      SnackbarHelper.showError(context, message: 'Vui lòng điền đầy đủ thông tin.');
                    }
                  },
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider(classId));

    return Scaffold(
      body: assignmentsAsync.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(child: Text('Chưa có BTVN nào được tạo.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  // CẬP NHẬT TỪ ĐÂY
                  title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        assignment.description.isEmpty ? '(Không có mô tả)' : assignment.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ngày học: ${DateFormat.yMd().format(assignment.sessionDate.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true, // Cho phép subtitle có nhiều dòng để hiển thị đầy đủ
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GradingScreen(
                          classId: classId,
                          assignment: assignment,
                        ),
                      ),
                    );
                  },
                  // ĐẾN ĐÂY
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateAssignmentDialog(context, ref);
        },
        label: const Text('Tạo BTVN'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}