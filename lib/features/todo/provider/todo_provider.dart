import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_v2/features/todo/models/todo_model.dart';
import 'package:todo_v2/features/todo/repository/todo_repository.dart';

class TodoNotifier extends AsyncNotifier<List<TodoModel>> {
  @override
  Future<List<TodoModel>> build() {
    return TodoRepository.instance.getTodos();
  }

  Future<void> addTodo(TodoModel todo) async {
    await TodoRepository.instance.insert(todo);
    ref.invalidateSelf();
  }

  Future<void> updateTodo(TodoModel todo) async {
    await TodoRepository.instance.update(todo);
    ref.invalidateSelf();
  }

  Future<void> deleteTodo(String id) async {
    await TodoRepository.instance.delete(id);
    ref.invalidateSelf();
  }

  Future<void> deleteCompleted() async {
    await TodoRepository.instance.deleteCompleted();
    ref.invalidateSelf();
  }

  Future<void> toggleComplete(TodoModel todo) async {
    final nowComplete = !todo.isComplete;
    final updated = todo.copyWith(
      isComplete: nowComplete,
      status: nowComplete ? TodoStatus.completed : TodoStatus.inProgress,
      completionDate: nowComplete ? DateTime.now() : null,
    );
    await TodoRepository.instance.update(updated);
    ref.invalidateSelf();
  }
}

final todoProvider = AsyncNotifierProvider<TodoNotifier, List<TodoModel>>(
  TodoNotifier.new,
);
