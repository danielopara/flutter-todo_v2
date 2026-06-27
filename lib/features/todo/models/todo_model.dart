import 'package:uuid/uuid.dart';

enum TodoStatus { notStarted, inProgress, completed }

enum TodoPriority { low, medium, high }

// Sentinel for copyWith to distinguish "set to null" from "leave unchanged".
const _absent = Object();

class TodoModel {
  final String id;
  final String title;
  final String description;
  final TodoStatus status;
  final TodoPriority priority;
  final bool isComplete;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? completionDate;

  const TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.status = TodoStatus.notStarted,
    required this.priority,
    this.isComplete = false,
    required this.createdAt,
    required this.dueDate,
    this.completionDate,
  });

  factory TodoModel.create({
    required String title,
    required String description,
    required TodoStatus status,
    required TodoPriority priority,
    required DateTime dueDate,
  }) {
    return TodoModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: status,
      priority: priority,
      isComplete: false,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    TodoStatus? status,
    TodoPriority? priority,
    bool? isComplete,
    DateTime? createdAt,
    DateTime? dueDate,
    Object? completionDate = _absent,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completionDate: completionDate == _absent
          ? this.completionDate
          : completionDate as DateTime?,
    );
  }

  Map<String, dynamic> todoToMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'isComplete': isComplete ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: TodoStatus.values.byName(map['status'] as String),
      priority: TodoPriority.values.byName(map['priority'] as String),
      isComplete: (map['isComplete'] as int? ?? 0) != 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: DateTime.parse(map['dueDate'] as String),
      completionDate: map['completionDate'] != null
          ? DateTime.parse(map['completionDate'] as String)
          : null,
    );
  }
}
