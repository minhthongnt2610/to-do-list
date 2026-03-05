import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension TimeOfDayExtensions on TimeOfDay {
  /// Hàm formatTimeOfDay để chuyển đổi thời gian từ TimeOfDay sang chuỗi với định dạng 12 giờ
  String formatTimeOfDay() {
    /// Lấy thời gian hiện tại
    final now = DateTime.now();

    /// Tạo một DateTime từ thời gian và ngày hiện tại
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    /// Định dạng thời gian theo 12 giờ
    final format = DateFormat.jm();

    /// Trả về chuỗi thời gian
    return format.format(dateTime);
  }

  /// Hàm toDateTime để chuyển đổi TimeOfDay sang DateTime
  DateTime toDateTime(DateTime baseDateTime) {
    return baseDateTime.copyWith(
      hour: hour,
      minute: minute,
    );
  }
}
