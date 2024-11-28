// lib/models/task.dart

import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title; // Title field for the task

  @HiveField(1)
  String description; // Description field for the task

  @HiveField(2)
  bool isCompleted; // Boolean field to track task completion

  @HiveField(3)
  DateTime? dueDate; // Optional due date field

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
  });
}
