// lib/src/features/ta_dashboard/widgets/class_settings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/class_model.dart';
import '../providers/class_providers.dart';

class ClassSettingsTab extends ConsumerStatefulWidget {
  final ClassModel classModel;
  const ClassSettingsTab({super.key, required this.classModel});

  @override
  ConsumerState<ClassSettingsTab> createState() => _ClassSettingsTabState();
}

class _ClassSettingsTabState extends ConsumerState<ClassSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _classNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _scheduleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu hiện tại của lớp học
    _classNameController = TextEditingController(text: widget.classModel.className);
    _descriptionController = TextEditingController(text: widget.classModel.description);
    _scheduleController = TextEditingController(text: widget.classModel.schedule);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _updateClassInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final updatedClass = ClassModel(
        id: widget.classModel.id,
        className: _classNameController.text.trim(),
        description: _descriptionController.text.trim(),
        schedule: _scheduleController.text.trim(),
        // Giữ lại các thông tin không thay đổi
        taId: widget.classModel.taId,
        taName: widget.classModel.taName,
        createdAt: widget.classModel.createdAt,
      );

      try {
        await ref.read(classRepositoryProvider).updateClass(updatedClass);
        if (mounted) {
          SnackbarHelper.showSuccess(context, message: 'Cập nhật thông tin lớp học thành công!');
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, message: 'Lỗi: $e');
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  Future<void> _deleteClass() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${widget.classModel.className}" không? Mọi dữ liệu liên quan sẽ không thể khôi phục.'),
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
      setState(() { _isLoading = true; });
      try {
        await ref.read(classRepositoryProvider).deleteClass(widget.classModel.id);
        if (mounted) {
          // Quay lại màn hình dashboard sau khi xóa thành công
          Navigator.of(context).pop();
          SnackbarHelper.showSuccess(context, message: 'Đã xóa lớp học thành công.');
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, message: 'Lỗi: $e');
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin cơ bản', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(labelText: 'Tên lớp học'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: 'Lịch học'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateClassInfo,
                  child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text('Lưu thay đổi'),
                ),
              ),
              const Divider(height: 48),
              Text('Khu vực nguy hiểm', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 8),
              const Text('Các hành động sau không thể hoàn tác. Hãy cẩn thận.'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _deleteClass,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Xóa lớp học này'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}