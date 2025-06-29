import 'package:flutter/material.dart';
import '../../widgets/modern_card.dart';
// 캘린더 패키지 임포트 (예시)
// import 'package:table_calendar/table_calendar.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<TodoItem> _todos = [
    TodoItem(
      id: '1',
      title: '소담이 건강검진',
      description: '정기 건강검진 및 체중 측정',
      cowName: '소담이 (002123456001)',
      type: TodoType.health,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      priority: Priority.high,
    ),
    TodoItem(
      id: '2',
      title: '꽃분이 분만 준비',
      description: '분만실 준비 및 분만용품 점검',
      cowName: '꽃분이 (002123456002)',
      type: TodoType.breeding,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
      priority: Priority.high,
    ),
    TodoItem(
      id: '3',
      title: '백신 접종 일정',
      description: '전체 소 대상 백신 접종',
      cowName: '전체',
      type: TodoType.vaccination,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
      priority: Priority.medium,
    ),
    TodoItem(
      id: '4',
      title: '사료 발주',
      description: '겨울 사료 발주 및 재고 관리',
      cowName: '전체',
      type: TodoType.feeding,
      dueDate: DateTime.now().add(const Duration(days: 14)),
      isCompleted: true,
      priority: Priority.low,
    ),
  ];

  // 더미 캘린더 일정 데이터
  final Map<DateTime, List<String>> _dummyEvents = {
    DateTime.utc(2024, 6, 10): ['백신접종', '건강검진'],
    DateTime.utc(2024, 6, 12): ['착유'],
    DateTime.utc(2024, 6, 15): ['사료배급'],
  };

  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('할일 관리'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 더미 캘린더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('더미 일정 캘린더', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                // 실제 캘린더 위젯으로 교체 가능
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _dummyEvents.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${entry.key.month}/${entry.key.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...entry.value.map((e) => Text(e, style: const TextStyle(fontSize: 12))).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // 실제 유저 할일 기반 캘린더 (구조만, 실제 연동은 추후)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('내 할일 캘린더', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _todos.map((todo) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${todo.dueDate.month}/${todo.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(todo.title, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildTodoSummary(),
          Expanded(
            child: _buildTodoItems(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 새로운 할일 추가 다이얼로그
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoSummary() {
    final totalTodos = _todos.length;
    final completedTodos = _todos.where((todo) => todo.isCompleted).length;
    final pendingTodos = totalTodos - completedTodos;
    final todayTodos = _todos.where((todo) => 
        !todo.isCompleted && 
        todo.dueDate.difference(DateTime.now()).inDays <= 1).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard('전체', totalTodos, const Color(0xFF4CAF50), Icons.assignment),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard('오늘', todayTodos, const Color(0xFFFF9800), Icons.today),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard('대기', pendingTodos, const Color(0xFF2196F3), Icons.pending_actions),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard('완료', completedTodos, const Color(0xFF9C27B0), Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return _buildTodoItem(todo);
      },
    );
  }

  Widget _buildTodoItem(TodoItem todo) {
    final isOverdue = !todo.isCompleted && todo.dueDate.isBefore(DateTime.now());
    final isToday = !todo.isCompleted && 
        todo.dueDate.difference(DateTime.now()).inDays == 0;

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _toggleTodoComplete(todo),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.isCompleted 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: todo.isCompleted 
                      ? const Color(0xFF4CAF50) 
                      : Colors.transparent,
                ),
                child: todo.isCompleted 
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTodoTypeColor(todo.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getTodoTypeIcon(todo.type),
                color: _getTodoTypeColor(todo.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: todo.isCompleted 
                                ? Colors.grey.shade500 
                                : const Color(0xFF2E3A59),
                            decoration: todo.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '지연',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '오늘',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todo.cowName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todo.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: todo.isCompleted 
                          ? Colors.grey.shade500 
                          : Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(todo.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      _buildPriorityChip(todo.priority),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        text = '높음';
        break;
      case Priority.medium:
        color = Colors.orange;
        text = '보통';
        break;
      case Priority.low:
        color = Colors.green;
        text = '낮음';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getTodoTypeColor(TodoType type) {
    switch (type) {
      case TodoType.health:
        return const Color(0xFF4CAF50);
      case TodoType.breeding:
        return const Color(0xFF2196F3);
      case TodoType.vaccination:
        return const Color(0xFF9C27B0);
      case TodoType.feeding:
        return const Color(0xFF795548);
      case TodoType.treatment:
        return const Color(0xFFE53935);
    }
  }

  IconData _getTodoTypeIcon(TodoType type) {
    switch (type) {
      case TodoType.health:
        return Icons.health_and_safety;
      case TodoType.breeding:
        return Icons.pregnant_woman;
      case TodoType.vaccination:
        return Icons.vaccines;
      case TodoType.feeding:
        return Icons.restaurant;
      case TodoType.treatment:
        return Icons.medical_services;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '내일';
    } else if (difference == -1) {
      return '어제';
    } else if (difference > 0) {
      return '$difference일 후';
    } else {
      return '${difference.abs()}일 전';
    }
  }

  void _toggleTodoComplete(TodoItem todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;
    });
  }
}

class TodoItem {
  final String id;
  final String title;
  final String description;
  final String cowName;
  final TodoType type;
  final DateTime dueDate;
  bool isCompleted;
  final Priority priority;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cowName,
    required this.type,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = Priority.medium,
  });
}

enum TodoType {
  health,
  breeding,
  vaccination,
  feeding,
  treatment,
}

enum Priority {
  high,
  medium,
  low,
} 