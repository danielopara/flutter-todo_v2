import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_v2/features/todo/models/todo_model.dart';
import 'package:todo_v2/features/todo/provider/todo_provider.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear completed',
            onPressed: () =>
                ref.read(todoProvider.notifier).deleteCompleted(),
          ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (todos) => todos.isEmpty
            ? const Center(
                child: Text(
                  'No todos yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                itemCount: todos.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _TodoTile(todo: todos[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddTodoDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TodoTile extends ConsumerWidget {
  final TodoModel todo;
  const _TodoTile({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(todoProvider.notifier).deleteTodo(todo.id),
      child: ListTile(
        leading: Checkbox(
          value: todo.isComplete,
          onChanged: (_) =>
              ref.read(todoProvider.notifier).toggleComplete(todo),
        ),
        title: Text(
          todo.title,
          style: todo.isComplete
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : null,
        ),
        subtitle: todo.description.isNotEmpty ? Text(todo.description) : null,
        trailing: _PriorityBadge(priority: todo.priority),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TodoPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      TodoPriority.high => (Colors.red, 'High'),
      TodoPriority.medium => (Colors.orange, 'Med'),
      TodoPriority.low => (Colors.green, 'Low'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AddTodoDialog extends ConsumerStatefulWidget {
  const _AddTodoDialog();

  @override
  ConsumerState<_AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<_AddTodoDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TodoPriority _priority = TodoPriority.medium;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String get _formattedDueDate =>
      '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final todo = TodoModel.create(
      title: title,
      description: _descController.text.trim(),
      status: TodoStatus.notStarted,
      priority: _priority,
      dueDate: _dueDate,
    );

    ref.read(todoProvider.notifier).addTodo(todo);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Todo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TodoPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TodoPriority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p.name[0].toUpperCase() + p.name.substring(1),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Due: $_formattedDueDate'),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
