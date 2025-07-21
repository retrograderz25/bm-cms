// lib/src/common/utils/excel_exporter.dart
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/class_model.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/submission_model.dart';

class ExcelExporter {
  // --- HÀM TRỢ GIÚP MỚI ---
  /// Tạo công thức Phân loại cho Excel.
  static String _getClassificationFormula(String scoreCell) {
    // Dịch lại công thức từ ảnh chụp màn hình của bạn
    // IF(score="", "", IF(score<5, "<5", IF(AND(score>=5, score<7), "5-7", ...)))
    return 'IF($scoreCell="","",IF($scoreCell<5,"<5",IF(AND($scoreCell>=5,$scoreCell<7),"5-7",IF(AND($scoreCell>=7,$scoreCell<8),"7-8",IF(AND($scoreCell>=8,$scoreCell<9),"8-9",IF($scoreCell>=9,">=9",""))))))';
  }

  /// Tạo công thức Xếp hạng cho Excel.
  static String _getRankFormula(String scoreCell, String scoreRange, String studentCount) {
    // Dịch lại công thức: IFERROR(RANK(score, score_range), "") & "/" & total_students
    return 'IFERROR(RANK($scoreCell,$scoreRange), "") & "/" & $studentCount';
  }


  static Future<void> generateComprehensiveGradeExcel({
    required ClassModel classModel,
    required AssignmentModel assignment,
    required List<EnrollmentModel> students,
    required List<SubmissionModel> submissions,
    // Dữ liệu điểm danh sẽ được thêm vào sau
  }) async {
    final submissionMap = {for (var s in submissions) s.studentId: s};
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Báo cáo tổng hợp'];

    // --- ĐỊNH DẠNG ---
    final CellStyle redHeaderStyle = CellStyle(
      backgroundColorHex: ExcelColor.yellowAccent,
      fontColorHex: ExcelColor.white,
      bold: true,
      verticalAlign: VerticalAlign.Center,
    );
    final CellStyle blueHeaderStyle = CellStyle(
      backgroundColorHex: ExcelColor.redAccent,
      fontColorHex: ExcelColor.white,
      bold: true,
      verticalAlign: VerticalAlign.Center,
    );

    // --- HEADER (THÔNG TIN CHUNG) ---
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue('GIÁO VIÊN');
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = redHeaderStyle;
    sheet.cell(CellIndex.indexByString("B1")).value = TextCellValue(classModel.teacherName ?? 'N/A');

    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue('LỚP');
    sheet.cell(CellIndex.indexByString("A2")).cellStyle = redHeaderStyle;
    sheet.cell(CellIndex.indexByString("B2")).value = TextCellValue(classModel.className);

    sheet.cell(CellIndex.indexByString("A3")).value = TextCellValue('NHÓM');
    sheet.cell(CellIndex.indexByString("A3")).cellStyle = redHeaderStyle;
    sheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(classModel.groupName ?? 'N/A');

    sheet.cell(CellIndex.indexByString("A4")).value = TextCellValue('TRỢ GIẢNG');
    sheet.cell(CellIndex.indexByString("A4")).cellStyle = redHeaderStyle;
    sheet.cell(CellIndex.indexByString("B4")).value = TextCellValue(classModel.taName);

    // --- GHI CHÚ ---
    sheet.cell(CellIndex.indexByString("E1")).value = TextCellValue('(*) Với học sinh lớp 10, 11 thì bảng điểm là điểm của buổi học hôm trước...');

    // --- BẢNG DỮ LIỆU ---
    // Merge header "NHẬN XÉT HỌC SINH"
    sheet.merge(CellIndex.indexByString("L6"), CellIndex.indexByString("N6"), customValue: TextCellValue("NHẬN XÉT HỌC SINH"));

    // Tiêu đề cột
    final headers = [
      'STT', 'Mã hs', 'Họ và tên', 'Điểm danh', 'Điểm BTVN', 'Phân loại',
      'Xếp hạng', 'Ngày học', 'Điểm danh (ngày/tháng/năm)', 'Chất lượng BTVN/ Luyện đề (*)',
      'Nhận xét khác (Nếu có)', 'Tên BTVN/ Luyện đề'
    ];
    // Đặt tên động cho cột Điểm BTVN
    headers[4] = 'Điểm ${assignment.title}';

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 6));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = blueHeaderStyle;
    }

    // Điền dữ liệu học sinh
    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final submission = submissionMap[student.studentId];
      final rowIndex = i + 7; // Dữ liệu bắt đầu từ hàng 8

      final studentCode = student.studentEmail.split('@').first;
      final grade = submission?.grade;

      // --- Dữ liệu tính toán (Phân loại, Xếp hạng) ---
      String classification = '';
      if (grade != null) {

      }
      // Xếp hạng tạm thời để trống
      String rank = 'N/A';

      // Điền vào các ô
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue((i + 1).toString());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(studentCode);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(student.studentName);
      // Cột điểm danh (để trống)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = DoubleCellValue(grade ?? 0);
      // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = TextCellValue(classification);
      // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = TextCellValue(rank);
      // Cột ngày học, điểm danh (để trống)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value = TextCellValue(submission?.qualityFeedback ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex)).value = TextCellValue(submission?.feedback ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex)).value = TextCellValue(assignment.title);
    }

    // Tự động điều chỉnh độ rộng
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    // Lưu và tải file
    if (kIsWeb) {
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());
        final fileName = 'BaoCao_${classModel.className.replaceAll(' ', '_')}_$formattedDate.xlsx';
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