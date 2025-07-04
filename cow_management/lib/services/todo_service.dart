import 'package:dio/dio.dart';
import '../models/todo.dart';
import 'dio_client.dart';

class TodoService {
  final DioClient _dioClient;

  TodoService(this._dioClient);

  // 할일 생성
  Future<Todo> createTodo(Map<String, dynamic> todoData) async {
    try {
      final response = await _dioClient.post('/api/todos/create', data: todoData);
      return Todo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 할일 목록 조회 (필터링 지원)
  Future<List<Todo>> getTodos({
    String? status,
    String? priority,
    String? category,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null && status.isNotEmpty) queryParams['status_filter'] = status;
      if (priority != null) queryParams['priority_filter'] = priority;
      if (category != null) queryParams['category_filter'] = category;

      final response = await _dioClient.get('/api/todos', queryParameters: queryParams);
      if (response.data is! List) {
        return [];
      }
      return (response.data as List)
          .map((json) => Todo.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // 할일 통계 조회
  Future<Map<String, dynamic>> getTodoStatistics() async {
    try {
      final response = await _dioClient.get('/api/todos/statistics');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 캘린더용 할일 조회
  Future<Map<DateTime, List<Todo>>> getCalendarTodos(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _dioClient.get(
        '/api/todos/calendar',
        queryParameters: {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      Map<DateTime, List<Todo>> result = {};
      (response.data['dates'] as Map<String, dynamic>).forEach((key, value) {
        final date = DateTime.parse(key);
        result[date] = (value as List)
            .map((json) => Todo.fromJson(json))
            .toList();
      });
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // 할일 상세 조회
  Future<Todo> getTodoById(String taskId) async {
    try {
      final response = await _dioClient.get('/api/todos/$taskId');
      return Todo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 할일 수정
  Future<Todo> updateTodo(String taskId, Map<String, dynamic> todoData) async {
    try {
      final response = await _dioClient.put('/api/todos/$taskId/update', data: todoData);
      return Todo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 할일 완료 처리
  Future<Todo> completeTodo(String taskId, {String? completionNotes}) async {
    try {
      final Map<String, dynamic> data = {};
      if (completionNotes != null) {
        data['completion_notes'] = completionNotes;
      }
      final response = await _dioClient.patch('/api/todos/$taskId/complete', data: data);
      return Todo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 할일 상태 변경
  Future<Todo> updateTodoStatus(
    String taskId,
    String status, {
    String? completionNotes,
  }) async {
    try {
      final response = await _dioClient.patch(
        '/api/todos/$taskId/status',
        data: {
          'status': status,
          'completion_notes': completionNotes,
        },
      );
      return Todo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // 할일 삭제
  Future<void> deleteTodo(String taskId) async {
    try {
      await _dioClient.delete('/api/todos/$taskId');
    } catch (e) {
      rethrow;
    }
  }
} 