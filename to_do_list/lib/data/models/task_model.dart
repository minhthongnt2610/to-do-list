import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/data/models/task_priority.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/extensions/time_of_day_extensions.dart';

import 'firebase/fb_task_model.dart';


class TaskModel {
  
  const TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  
  final String? id;

  
  final String name;

  
  final String description;

  
  final TimeOfDay startTime;

  
  final TimeOfDay endTime;

  
  final DateTime date;

  
  final TaskPriority priority;

  
  final TaskStatus status;

  
  final DateTime createdAt;

  
  final DateTime? updatedAt;

  
  TaskModel copyWith({
    String? id,
    String? name,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? date,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'date': date.millisecondsSinceEpoch,
      'priority': priority.index,
      'status': status.index,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return "TaskModel(id: $id, name: $name, description: $description, startTime: $startTime, endTime: $endTime, date: $date, priority: $priority, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)";
  }
}


extension TaskModelExtension on TaskModel {
  
  String get displayDate {
    final dateFormat = DateFormat('d MMM');
    return dateFormat.format(date);
  }

  
  FbTaskModel toFbTaskModel() {
    return FbTaskModel(
      id: id.toString(),
      name: name,
      description: description,
      startTime: startTime.toDateTime(date).millisecondsSinceEpoch,
      endTime: endTime.toDateTime(date).millisecondsSinceEpoch,
      date: date.millisecondsSinceEpoch,
      priority: priority.index,
      status: status.index,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt?.millisecondsSinceEpoch,
    );
  }
}
