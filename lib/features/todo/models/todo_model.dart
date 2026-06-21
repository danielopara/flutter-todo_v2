import 'package:uuid/uuid.dart';

enum TodoStatus { notStarted, inProgress, completed }

enum TodoPriority { low, medium, high }

class TodoModel {
  final String id;
  final String title;
  final String description;
  final TodoStatus status;
  final TodoPriority priority;
  final bool isComplete;
  final DateTime? createdAt;
  final DateTime dueDate;
  final DateTime? completionDate;

  const TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.status = TodoStatus.notStarted,
    required this.priority,
    this.isComplete = false,
    this.createdAt,
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
      completionDate: null,
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
    DateTime? completionDate,
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
      completionDate: completionDate ?? this.completionDate,
    );
  }

  Map<String, dynamic> todoToMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'isComplete': isComplete,
      'createdAt': createdAt?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: TodoStatus.values.firstWhere(
        (e) => e.toString() == 'TodoStatus.${map['status']}',
        orElse: () => TodoStatus.notStarted,
      ),
      priority: TodoPriority.values.firstWhere(
        (e) => e.toString() == 'TodoPriority.${map['priority']}',
        orElse: () => TodoPriority.low,
      ),
      isComplete: map['isComplete'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      dueDate: DateTime.parse(map['dueDate'] as String),
      completionDate: map['completionDate'] != null
          ? DateTime.parse(map['completionDate'] as String)
          : null,
    );
  }
}
