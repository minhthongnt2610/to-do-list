import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_priority.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/extensions/date_time_extensions.dart';


class FbTaskModel {
  
  const FbTaskModel({
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

  
  final int startTime;

  
  final int endTime;

  
  final int date;

  
  final int priority;

  
  final int status;

  
  final int createdAt;

  
  final int? updatedAt;

  
  FbTaskModel copyWith({
    String? id,
    String? name,
    String? description,
    int? startTime,
    int? endTime,
    int? date,
    int? priority,
    int? status,
    int? createdAt,
    int? updatedAt,
  }) {
    return FbTaskModel(
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
      
      'name': name,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'date': date,
      'priority': priority,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FbTaskModel.fromJson(Map<String, dynamic> json, String id) {
    return FbTaskModel(
      id: id,
      name: json['name'],
      description: json['description'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      date: json['date'],
      priority: json['priority'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  String toString() {
    return 'DbTaskModel{id: $id, name: $name, description: $description, startTime: $startTime, endTime: $endTime, date: $date, priority: $priority, status: $status, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}


extension FbTaskModelExtension on FbTaskModel {
  
  TaskModel toTaskModel() {
    return TaskModel(
      id: id,
      name: name,
      description: description,
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime).toTimeOfDay(),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime).toTimeOfDay(),
      date: DateTime.fromMillisecondsSinceEpoch(date),
      priority: TaskPriority.values[priority],
      status: TaskStatus.values[status],
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
          : null,
    );
  }
}
