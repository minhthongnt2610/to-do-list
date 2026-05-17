import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_priority.dart';

class ExcelExportService {
  /// Xuất danh sách task ra file Excel và chia sẻ
  Future<void> exportTasksToExcel(List<TaskModel> tasks) async {
    final excel = Excel.createExcel();

    // Đổi tên sheet mặc định
    excel.rename('Sheet1', 'Tasks');
    final sheet = excel['Tasks'];

    // --- Header row ---
    final headers = [
      'STT',
      'Tên công việc',
      'Mô tả',
      'Ngày',
      'Giờ bắt đầu',
      'Giờ kết thúc',
      'Độ ưu tiên',
      'Trạng thái',
    ];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#BA83DE'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // --- Data rows ---
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final rowIndex = i + 1;

      // Lấy tên priority từ extension
      final priorityTitle = _getPriorityTitle(task.priority);
      final statusTitle = task.status.name == 'complete'
          ? 'Hoàn thành'
          : 'Chưa hoàn thành';

      final startTimeDate = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        task.startTime.hour,
        task.startTime.minute,
      );
      final endTimeDate = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        task.endTime.hour,
        task.endTime.minute,
      );

      final rowData = [
        (i + 1).toString(),
        task.name,
        task.description,
        dateFormat.format(task.date),
        timeFormat.format(startTimeDate),
        timeFormat.format(endTimeDate),
        priorityTitle,
        statusTitle,
      ];

      final evenRowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#1E1E2E'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
      final oddRowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#2A2A3E'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      for (var col = 0; col < rowData.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
        );
        cell.value = TextCellValue(rowData[col]);
        cell.cellStyle = rowIndex.isEven ? evenRowStyle : oddRowStyle;
      }
    }

    // Set column widths
    sheet.setColumnWidth(0, 6);   // STT
    sheet.setColumnWidth(1, 30);  // Tên
    sheet.setColumnWidth(2, 40);  // Mô tả
    sheet.setColumnWidth(3, 14);  // Ngày
    sheet.setColumnWidth(4, 14);  // Giờ bắt đầu
    sheet.setColumnWidth(5, 14);  // Giờ kết thúc
    sheet.setColumnWidth(6, 14);  // Độ ưu tiên
    sheet.setColumnWidth(7, 18);  // Trạng thái

    // Lưu file vào thư mục tạm
    final fileBytes = excel.save();
    if (fileBytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'tasks_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${tempDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    // Chia sẻ file
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Danh sách công việc của tôi',
      subject: 'Xuất danh sách task',
    );
  }

  String _getPriorityTitle(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.low:
        return 'Thấp';
    }
  }
}
