// lib/src/features/ta_dashboard/widgets/announcement_list_tab.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/user_model.dart';
import '../../authentication/providers/auth_providers.dart';
import '../providers/class_providers.dart';

// Enum để định nghĩa các lựa chọn trong menu, giúp code an toàn và dễ đọc
enum _MenuOption { edit, delete }

class AnnouncementListTab extends ConsumerWidget {
  final String classId;
  const AnnouncementListTab({super.key, required this.classId});

  // --- HÀM TẠO THÔNG BÁO ---
  void _showCreateAnnouncementDialog(BuildContext context, WidgetRef ref, UserModel currentUser) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tạo thông báo mới'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Nội dung'),
                    maxLines: 5,
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
                  final newAnnouncement = AnnouncementModel(
                    id: '',
                    classId: classId,
                    title: titleController.text,
                    content: contentController.text,
                    taName: currentUser.displayName,
                    createdAt: Timestamp.now(),
                  );
                  try {
                    await ref.read(classRepositoryProvider).createAnnouncement(newAnnouncement);
                    Navigator.pop(context);
                    SnackbarHelper.showSuccess(context, message: 'Đăng thông báo thành công!');
                  } catch (e) {
                    SnackbarHelper.showError(context, message: 'Lỗi: $e');
                  }
                }
              },
              child: const Text('Đăng'),
            ),
          ],
        );
      },
    );
  }

  // --- HÀM SỬA THÔNG BÁO ---
  void _showEditAnnouncementDialog(BuildContext context, WidgetRef ref, AnnouncementModel announcement) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: announcement.title);
    final contentController = TextEditingController(text: announcement.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa thông báo'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Nội dung'),
                    maxLines: 5,
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
                  final updatedAnnouncement = AnnouncementModel(
                    id: announcement.id,
                    classId: announcement.classId,
                    title: titleController.text,
                    content: contentController.text,
                    taName: announcement.taName,
                    createdAt: announcement.createdAt,
                  );
                  try {
                    await ref.read(classRepositoryProvider).updateAnnouncement(updatedAnnouncement);
                    Navigator.pop(context);
                    SnackbarHelper.showSuccess(context, message: 'Cập nhật thông báo thành công!');
                  } catch (e) {
                    SnackbarHelper.showError(context, message: 'Lỗi: $e');
                  }
                }
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        );
      },
    );
  }

  // --- HÀM XÓA THÔNG BÁO ---
  Future<void> _deleteAnnouncement(BuildContext context, WidgetRef ref, AnnouncementModel announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thông báo "${announcement.title}" không?'),
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
        await ref.read(classRepositoryProvider).deleteAnnouncement(announcement.id);
        if (context.mounted) {
          SnackbarHelper.showSuccess(context, message: 'Đã xóa thông báo.');
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarHelper.showError(context, message: 'Lỗi khi xóa: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider(classId));
    final currentUserAsync = ref.watch(userDataProvider(ref.watch(authStateChangesProvider).asData!.value!.uid));

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
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text(
                      'Đăng bởi ${announcement.taName} - ${DateFormat.yMd().add_jm().format(announcement.createdAt.toDate())}\n\n${announcement.content}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<_MenuOption>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Tùy chọn',
                    onSelected: (option) {
                      if (option == _MenuOption.edit) {
                        _showEditAnnouncementDialog(context, ref, announcement);
                      } else if (option == _MenuOption.delete) {
                        _deleteAnnouncement(context, ref, announcement);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _MenuOption.edit,
                        child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Sửa')),
                      ),
                      const PopupMenuItem(
                        value: _MenuOption.delete,
                        child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Xóa')),
                      ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Lấy dữ liệu user từ provider đã watch
          final currentUser = currentUserAsync.asData?.value;
          if (currentUser != null) {
            _showCreateAnnouncementDialog(context, ref, currentUser);
          }
        },
        label: const Text('Tạo thông báo'),
        icon: const Icon(Icons.add_comment),
      ),
    );
  }
}