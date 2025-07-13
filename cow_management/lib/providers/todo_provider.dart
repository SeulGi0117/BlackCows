import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  final TodoService _todoService;

  List<Todo> _todos = [];
  Map<DateTime, List<Todo>> _calendarTodos = {};
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  String _currentStatusFilter = '';

  TodoProvider(this._todoService);

  // GETTERS
  List<Todo> get todos => _todos;
  Map<DateTime, List<Todo>> get calendarTodos => _calendarTodos;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentStatusFilter => _currentStatusFilter;

  List<Todo> get filteredTodos => _currentStatusFilter.isEmpty
      ? _todos
      : _todos.where((t) => t.status == _currentStatusFilter).toList();

  // HELPERS
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(Object e) {
    _error = e.toString();
    notifyListeners();
  }

  void _replaceTodoById(String id, Todo newTodo) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) _todos[index] = newTodo;
  }

  // READ
  Future<void> loadTodos(
      {String? status, String? priority, String? category}) async {
    _setLoading(true);
    _error = null;

    try {
      _currentStatusFilter = status ?? '';
      _todos = await _todoService.getTodos(
        status: status,
        priority: priority,
        category: category,
      );
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCalendarTodos(DateTime startDate, DateTime endDate) async {
    _setLoading(true);
    _error = null;

    try {
      _calendarTodos = await _todoService.getCalendarTodos(startDate, endDate);
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStatistics() async {
    _setLoading(true);
    _error = null;

    try {
      _statistics = await _todoService.getTodoStatistics();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // CREATE
  Future<Todo?> createTodo(Todo todo) async {
    _setLoading(true);
    _error = null;

    try {
      final createdTodo = await _todoService.createTodo(todo);
      _todos.add(createdTodo);
      notifyListeners();
      return createdTodo;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // UPDATE
  Future<Todo?> updateTodo(String taskId, Todo todo) async {
    _setLoading(true);
    _error = null;

    try {
      final updated = await _todoService.updateTodo(taskId, todo);
      _replaceTodoById(taskId, updated);
      notifyListeners();
      return updated;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Todo?> updateTodoStatus(
    String taskId,
    String status, {
    String? completionNotes,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final updated = await _todoService.updateTodoStatus(
        taskId,
        status,
        completionNotes: completionNotes,
      );
      _replaceTodoById(taskId, updated);
      notifyListeners();
      return updated;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Todo?> completeTodo(String taskId, {String? completionNotes}) async {
    return updateTodoStatus(taskId, TodoStatus.completed,
        completionNotes: completionNotes);
  }

  // DELETE
  Future<bool> deleteTodo(String taskId) async {
    _setLoading(true);
    _error = null;

    try {
      await _todoService.deleteTodo(taskId);
      _todos.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ETC
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
