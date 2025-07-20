// lib/src/features/ta_dashboard/widgets/student_list_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../providers/class_providers.dart';

class StudentListTab extends ConsumerWidget {
  final String classId;
  const StudentListTab({super.key, required this.classId});

  // Hàm hiển thị dialog thêm học sinh
  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm học sinh'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email của học sinh',
                hintText: 'student@example.com',
              ),
              validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email không hợp lệ' : null,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final studentEmail = emailController.text.trim();
                  // Hiển thị loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    await ref.read(classRepositoryProvider).addStudentToClass(
                      studentEmail: studentEmail,
                      classId: classId,
                    );
                    Navigator.of(context).pop(); // Đóng loading
                    Navigator.of(context).pop(); // Đóng dialog thêm HS
                    SnackbarHelper.showSuccess(context, message: 'Thêm học sinh thành công!');
                  } catch (e) {
                    Navigator.of(context).pop(); // Đóng loading
                    SnackbarHelper.showError(context, message: e.toString());
                  }
                }
              },
              child: const Text('Thêm'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentListAsync = ref.watch(studentListProvider(classId));

    return Scaffold(
      body: studentListAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Chưa có học sinh nào trong lớp.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: CircleAvatar(child: Text(student.studentName.substring(0, 1).toUpperCase())),
                title: Text(student.studentName),
                subtitle: Text(student.studentEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Xóa học sinh',
                  onPressed: () {
                    // TODO: Thêm logic xóa học sinh
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(context, ref),
        label: const Text('Thêm học sinh'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}