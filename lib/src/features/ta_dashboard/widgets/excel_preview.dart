// lib/src/features/ta_dashboard/widgets/excel_preview.dart
import 'package:flutter/material.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/submission_model.dart';

class ExcelPreview extends StatelessWidget {
  final List<EnrollmentModel> students;
  final List<SubmissionModel> submissions;

  const ExcelPreview({
    super.key,
    required this.students,
    required this.submissions,
  });

  @override
  Widget build(BuildContext context) {
    final submissionMap = {for (var s in submissions) s.studentId: s};

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: SingleChildScrollView( // Cho phép cuộn dọc
        child: SingleChildScrollView( // Cho phép cuộn ngang
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('STT', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Mã HS', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Họ và Tên', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Điểm', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Nhận xét', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(students.length, (index) {
              final student = students[index];
              final submission = submissionMap[student.studentId];
              final studentCode = student.studentEmail.split('@').first;

              return DataRow(cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(studentCode)),
                DataCell(Text(student.studentName)),
                DataCell(Text(student.studentEmail)),
                DataCell(Text(submission?.grade?.toString() ?? '')),
                DataCell(Text(submission?.feedback ?? '')),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}