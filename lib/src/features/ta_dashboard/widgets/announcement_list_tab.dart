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

class AnnouncementListTab extends ConsumerWidget {
  final String classId;
  const AnnouncementListTab({super.key, required this.classId});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider(classId));
    final currentUser = ref.watch(userDataProvider(ref.watch(authStateChangesProvider).asData!.value!.uid));

    return Scaffold(
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(child: Text('Chưa có thông báo nào.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Đăng bởi ${announcement.taName} - ${DateFormat.yMd().add_jm().format(announcement.createdAt.toDate())}\n\n${announcement.content}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  isThreeLine: true,
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
          if (currentUser.hasValue) {
            _showCreateAnnouncementDialog(context, ref, currentUser.value!);
          }
        },
        label: const Text('Tạo thông báo'),
        icon: const Icon(Icons.add_comment),
      ),
    );
  }
}