import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Lớp mở rộng cho DateTime
extension DateTimeExtensions on DateTime {
  /// Trả về ngày đầu tuần của ngày hiện tại
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1));
  }

  /// Trả về ngày cuối tuần của ngày hiện tại
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday));
  }

  /// Trả về ngày tuần sau của ngày hiện tại
  DateTime get nextWeek {
    return add(const Duration(days: 7));
  }

  /// Trả về ngày tuần trước của ngày hiện tại
  DateTime get previousWeek {
    return subtract(const Duration(days: 7));
  }

  /// Trả về danh sách ngày trong tuần của ngày hiện tại
  List<DateTime> get daysPerWeek {
    final firstDay = startOfWeek;
    return List.generate(7, (index) => firstDay.add(Duration(days: index)));
  }

  /// Hiển thị ngày dưới dạng chuỗi
  String displayDateString({
    String format = 'dd MMM',
  }) {
    final dateFormat = DateFormat(format);
    return dateFormat.format(this);
  }

  /// Hiển thị ngày
  String displayDayString() {
    return DateFormat('dd').format(this);
  }

  /// Hiển thị thứ trong tuần
  String displayWeekdayString() {
    return DateFormat('E').format(this);
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }
}
