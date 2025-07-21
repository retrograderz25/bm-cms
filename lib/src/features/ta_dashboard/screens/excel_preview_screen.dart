// lib/src/features/ta_dashboard/screens/excel_preview_screen.dart
import 'package:flutter/material.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/submission_model.dart';
import '../widgets/excel_preview.dart';

class ExcelPreviewScreen extends StatelessWidget {
  final List<EnrollmentModel> students;
  final List<SubmissionModel> submissions;

  const ExcelPreviewScreen({
    super.key,
    required this.students,
    required this.submissions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước Bảng điểm'),
      ),
      body: ExcelPreview(
        students: students,
        submissions: submissions,
      ),
    );
  }
}