// lib/src/features/ta_dashboard/screens/ta_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/user_model.dart';
import '../../authentication/providers/auth_providers.dart';
import '../providers/class_providers.dart';
import 'class_detail_screen.dart';
// import 'class_detail_screen.dart'; // Sẽ dùng ở giai đoạn sau

class TaDashboardScreen extends ConsumerWidget {
  const TaDashboardScreen({super.key});

  // Hàm hiển thị dialog để tạo lớp mới (không thay đổi)
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.asData?.value;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userModelAsync = ref.watch(userDataProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(userModelAsync.asData?.value?.displayName ?? 'TA Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          )
        ],
      ),
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
              // SỬ DỤNG LAYOUTBUILDER ĐỂ TẠO GIAO DIỆN RESPONSIVE
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Breakpoint: 600dp
                  if (constraints.maxWidth < 600) {
                    // Màn hình hẹp (điện thoại): Dùng ListView
                    return _buildClassListView(context, classes);
                  } else {
                    // Màn hình rộng (máy tính bảng/máy tính): Dùng GridView
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

  // Widget riêng để build ListView
  Widget _buildClassListView(BuildContext context, List<ClassModel> classes) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final aClass = classes[index];
        // Truyền context vào _buildClassCard
        return _buildClassCard(context, aClass);
      },
    );
  }
  // Widget riêng để build GridView
  Widget _buildClassGridView(BuildContext context, List<ClassModel> classes) {
    // Tính toán số cột dựa trên chiều rộng
    final screenWidth = MediaQuery.of(context).size.width; // Bây giờ nó sẽ hoạt động
    // Cứ mỗi 450px thì thêm 1 cột, tối thiểu 2 cột, tối đa 4 cột
    final crossAxisCount = (screenWidth / 450).floor().clamp(2, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3 / 1.5, // Tỷ lệ W/H của mỗi card
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final aClass = classes[index];
        // Truyền context vào _buildClassCard
        return _buildClassCard(context, aClass);
      },
    );
  }

  // Widget chung để build Card cho một lớp học (để tái sử dụng)
  Widget _buildClassCard(BuildContext context, ClassModel aClass) {
    return Card(
      clipBehavior: Clip.antiAlias, // Để InkWell có hiệu ứng bo góc
      child: InkWell( // Thêm hiệu ứng gợn sóng khi nhấn
        onTap: () {
          // TODO: Giai đoạn 3: Điều hướng đến trang chi tiết lớp học
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClassDetailScreen(classModel: aClass)));
          // SnackbarHelper.showSuccess(context, message: "Chi tiết lớp ${aClass.className}");
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                aClass.className,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  aClass.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(aClass.schedule, style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}