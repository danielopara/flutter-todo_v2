import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_v2/features/todo/models/todo_model.dart';

class TodoRepository {
  TodoRepository._internal();
  static final TodoRepository instance = TodoRepository._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            priority TEXT NOT NULL,
            isComplete INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            completionDate TEXT
          )
        ''');
      },
    );
  }

  Future<List<TodoModel>> getTodos() async {
    final db = await database;
    final rows = await db.query('todos', orderBy: 'createdAt DESC');
    return rows.map(TodoModel.fromMap).toList();
  }

  Future<void> insert(TodoModel todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.todoToMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(TodoModel todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.todoToMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCompleted() async {
    final db = await database;
    await db.delete('todos', where: 'isComplete = 1');
  }
}
