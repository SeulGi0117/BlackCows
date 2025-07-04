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

  List<Todo> get todos => _todos;
  Map<DateTime, List<Todo>> get calendarTodos => _calendarTodos;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentStatusFilter => _currentStatusFilter;
  List<Todo> get filteredTodos => _currentStatusFilter.isEmpty
      ? _todos
      : _todos.where((t) => t.status == _currentStatusFilter).toList();

  Future<void> loadTodos({
    String? status,
    String? priority,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentStatusFilter = status ?? '';
      _todos = await _todoService.getTodos(
        status: status,
        priority: priority,
        category: category,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _todoService.getTodoStatistics();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Todo?> createTodo(Map<String, dynamic> todoData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final todo = await _todoService.createTodo(todoData);
      _todos = [..._todos, todo];
      notifyListeners();
      return todo;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Todo?> updateTodo(String taskId, Map<String, dynamic> todoData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final todo = await _todoService.updateTodo(taskId, todoData);
      _todos = _todos.map((t) => t.id == taskId ? todo : t).toList();
      notifyListeners();
      return todo;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTodo(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _todoService.deleteTodo(taskId);
      _todos = _todos.where((t) => t.id != taskId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Todo?> completeTodo(String taskId, {String? completionNotes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final todo = await _todoService.completeTodo(taskId, completionNotes: completionNotes);
      _todos = _todos.map((t) => t.id == taskId ? todo : t).toList();
      notifyListeners();
      return todo;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCalendarTodos(DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _calendarTodos = await _todoService.getCalendarTodos(startDate, endDate);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Todo?> updateTodoStatus(
    String taskId,
    String status, {
    String? completionNotes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedTodo = await _todoService.updateTodoStatus(
        taskId,
        status,
        completionNotes: completionNotes,
      );
      final index = _todos.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }

      _isLoading = false;
      notifyListeners();
      return updatedTodo;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 