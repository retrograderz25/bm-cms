// lib/src/common/utils/excel_exporter.dart
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // Thêm import này
import '../../data/models/enrollment_model.dart';
import '../../data/models/submission_model.dart';

class ExcelExporter {
  static Future<void> generateGradeExcel({
    required String className,
    required String assignmentTitle,
    required List<EnrollmentModel> students,
    required List<SubmissionModel> submissions,
  }) async {
    final submissionMap = {for (var s in submissions) s.studentId: s};
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Bảng điểm chi tiết'];

    final CellStyle titleStyle = CellStyle(bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center);
    final CellStyle headerStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.blueAccent);

    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("F1")); // Merge 6 cột
    final titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value = TextCellValue('BẢNG ĐIỂM CHI TIẾT LỚP: $className');
    titleCell.cellStyle = titleStyle;

    sheet.merge(CellIndex.indexByString("A2"), CellIndex.indexByString("F2")); // Merge 6 cột
    final assignmentCell = sheet.cell(CellIndex.indexByString("A2"));
    assignmentCell.value = TextCellValue('BÀI TẬP: $assignmentTitle');

    // THÊM CỘT "MÃ HỌC SINH"
    final headers = ['STT', 'Mã học sinh', 'Họ và Tên', 'Email', 'Điểm', 'Nhận xét'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final submission = submissionMap[student.studentId];
      final rowIndex = i + 4;

      // Logic lấy mã học sinh từ email
      final studentCode = student.studentEmail.split('@').first;

      // CẬP NHẬT LẠI VỊ TRÍ CÁC CỘT
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue((i + 1).toString());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(studentCode);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(student.studentName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = TextCellValue(student.studentEmail);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = DoubleCellValue(submission?.grade ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = TextCellValue(submission?.feedback ?? '');
    }

    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    if (kIsWeb) {
      final fileBytes = excel.save();
      if (fileBytes != null) {
        // TẠO TÊN FILE MỚI
        final formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());
        final fileName = '${assignmentTitle.replaceAll(' ', '_')}_$formattedDate.xlsx';

        final base64 = base64Encode(fileBytes);
        html.AnchorElement(
          href: 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64',
        )
          ..setAttribute('download', fileName)
          ..click();
      }
    }
  }
}