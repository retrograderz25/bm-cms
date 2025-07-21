// lib/src/features/admin/widgets/user_management_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/user_model.dart';
import '../../authentication/providers/auth_providers.dart';
import '../providers/admin_providers.dart';

enum _UserMenuOption { delete }

class UserManagementTab extends ConsumerWidget {
  const UserManagementTab({super.key});

  // --- HÀM MỚI: XỬ LÝ XÓA NGƯỜI DÙNG ---
  Future<void> _deleteUser(BuildContext context, WidgetRef ref, UserModel userToDelete) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${userToDelete.displayName}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authRepositoryProvider).deleteUserDoc(userToDelete.uid);
        if (context.mounted) {
          SnackbarHelper.showSuccess(context, message: 'Đã xóa người dùng.');
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarHelper.showError(context, message: 'Lỗi: $e');
        }
      }
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy thông tin của Admin hiện tại để so sánh
    final currentAdminId = ref.watch(authStateChangesProvider).asData?.value?.uid;
    final allUsersAsync = ref.watch(allUsersProvider);

    return allUsersAsync.when(
      data: (users) {
        // --- LỌC DANH SÁCH NGƯỜI DÙNG ---
        // Chỉ hiển thị những người dùng không phải là Admin hiện tại
        final filteredUsers = users.where((user) => user.uid != currentAdminId).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text('Không có người dùng nào để quản lý.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            // Kiểm tra xem user này có phải là admin không
            final isTargetUserAdmin = user.role == UserRole.admin;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isTargetUserAdmin ? Colors.amber : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    isTargetUserAdmin ? Icons.policy_rounded : (user.role == UserRole.ta ? Icons.person_rounded : Icons.school_rounded),
                    color: Colors.white,
                  ),
                ),
                title: Text(user.displayName),
                subtitle: Text('${user.email}\nRole: ${user.role.name}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- NÚT SỬA ---
                    // Vô hiệu hóa nút sửa nếu user đích là Admin
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      tooltip: isTargetUserAdmin ? 'Không thể sửa Admin khác' : 'Sửa người dùng',
                      onPressed: isTargetUserAdmin ? null : () {
                        _showEditUserDialog(context, ref, user);
                      },
                    ),
                    // --- NÚT XÓA (TRONG MENU) ---
                    // Vô hiệu hóa nút xóa nếu user đích là Admin
                    PopupMenuButton<_UserMenuOption>(
                      tooltip: 'Tùy chọn khác',
                      enabled: !isTargetUserAdmin, // Vô hiệu hóa toàn bộ menu
                      onSelected: (option) {
                        if (option == _UserMenuOption.delete) {
                          _deleteUser(context, ref, user);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: _UserMenuOption.delete,
                          child: ListTile(leading: Icon(Icons.delete_forever, color: Colors.red), title: Text('Xóa người dùng', style: TextStyle(color: Colors.red))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi tải người dùng: $err')),
    );
  }

  // Dialog _showEditUserDialog không đổi, chỉ cần đảm bảo nó tồn tại trong class này
  void _showEditUserDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.displayName);
    final gradeController = TextEditingController(text: user.gradeLevel ?? '');

    UserRole selectedRole = user.role;
    StudentStatus? selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Sửa thông tin: ${user.displayName}'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                        validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                      ),
                      const SizedBox(height: 16),
                      // Admin không thể nâng người khác lên làm Admin
                      DropdownButtonFormField<UserRole>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Vai trò'),
                        items: UserRole.values
                            .where((role) => role != UserRole.unknown && role != UserRole.admin)
                            .map((role) => DropdownMenuItem(value: role, child: Text(role.name)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedRole = value);
                          }
                        },
                      ),
                      if (selectedRole == UserRole.student) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<StudentStatus>(
                          value: selectedStatus ?? StudentStatus.active,
                          decoration: const InputDecoration(labelText: 'Trạng thái'),
                          items: StudentStatus.values
                              .map((status) => DropdownMenuItem(value: status, child: Text(status.name)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: gradeController,
                          decoration: const InputDecoration(labelText: 'Khối/Cấp độ'),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final updatedUser = UserModel(
                        uid: user.uid, email: user.email, displayName: nameController.text.trim(),
                        role: selectedRole, status: selectedRole == UserRole.student ? selectedStatus : null,
                        gradeLevel: selectedRole == UserRole.student ? gradeController.text.trim() : null,
                        createdAt: user.createdAt, photoUrl: user.photoUrl,
                      );

                      try {
                        await ref.read(authRepositoryProvider).updateUser(updatedUser);
                        Navigator.pop(context);
                        SnackbarHelper.showSuccess(context, message: 'Cập nhật thành công!');
                      } catch (e) {
                        SnackbarHelper.showError(context, message: 'Lỗi: $e');
                      }
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}