// lib/src/features/ta_dashboard/widgets/out_class_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/user_model.dart';
import '../../authentication/providers/auth_providers.dart';
import '../providers/class_providers.dart';
import '../screens/class_detail_screen.dart';

class OutClassView extends ConsumerWidget {
  const OutClassView({super.key});

  // --- CÁC HÀM HELPER ĐƯỢC CHUYỂN VÀO ĐÂY ---

  void _showCreateClassDialog(BuildContext context, WidgetRef ref, UserModel currentUser) {
    final formKey = GlobalKey<FormState>();
    final classNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final scheduleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tạo lớp học mới'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: classNameController,
                    decoration: const InputDecoration(labelText: 'Tên lớp học'),
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: scheduleController,
                    decoration: const InputDecoration(labelText: 'Lịch học (VD: Thứ 2, 18:00)'),
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newClass = ClassModel(
                    id: '',
                    className: classNameController.text,
                    description: descriptionController.text,
                    schedule: scheduleController.text,
                    taId: currentUser.uid,
                    taName: currentUser.displayName,
                    createdAt: Timestamp.now(),
                  );
                  try {
                    await ref.read(classRepositoryProvider).createClass(newClass);
                    Navigator.pop(context);
                    SnackbarHelper.showSuccess(context, message: 'Tạo lớp thành công!');
                  } catch (e) {
                    SnackbarHelper.showError(context, message: 'Lỗi: $e');
                  }
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassListView(BuildContext context, List<ClassModel> classes) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final aClass = classes[index];
        return _buildClassCard(context, aClass);
      },
    );
  }

  Widget _buildClassGridView(BuildContext context, List<ClassModel> classes) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 450).floor().clamp(2, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3 / 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final aClass = classes[index];
        return _buildClassCard(context, aClass);
      },
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel aClass) {
    return SizedBox(
      // Giới hạn chiều cao của Card, đặc biệt quan trọng cho ListView trên mobile
      height: 120,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ClassDetailScreen(classModel: aClass)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Sử dụng Stack để định vị icon mũi tên một cách linh hoạt
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy các phần tử ra 2 đầu
              children: [
                // Phần trên: Tên lớp và mô tả
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aClass.className,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aClass.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      maxLines: 1, // Chỉ 1 dòng mô tả cho gọn
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // Phần dưới: Lịch học
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(aClass.schedule, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateChangesProvider).asData?.value;
    if (currentUser == null) return const Center(child: Text("Đang tải người dùng..."));

    final userModelAsync = ref.watch(userDataProvider(currentUser.uid));

    return Scaffold(
      body: userModelAsync.when(
        data: (userModel) {
          if (userModel == null) return const Center(child: Text("Không tìm thấy thông tin TA."));

          final classesAsync = ref.watch(taClassesProvider(userModel.uid));

          return classesAsync.when(
            data: (classes) {
              if (classes.isEmpty) {
                return const Center(
                  child: Text('Bạn chưa quản lý lớp học nào.\nHãy tạo một lớp mới!', textAlign: TextAlign.center),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return _buildClassListView(context, classes);
                  } else {
                    return _buildClassGridView(context, classes);
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi tải danh sách lớp: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải thông tin người dùng: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final userModel = userModelAsync.asData?.value;
          if (userModel != null) {
            _showCreateClassDialog(context, ref, userModel);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo lớp học mới',
      ),
    );
  }
}