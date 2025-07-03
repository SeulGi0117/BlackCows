import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_utils.dart';
import 'todo_add_page.dart';
import 'todo_detail_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _statusFilter;
  String? _priorityFilter;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final todoProvider = context.read<TodoProvider>();
    await Future.wait([
      todoProvider.loadTodos(
        status: _statusFilter,
        priority: _priorityFilter,
        category: _categoryFilter,
      ),
      todoProvider.loadTodayTodos(),
      todoProvider.loadOverdueTodos(),
      todoProvider.loadStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '오늘'),
            Tab(text: '지연'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorUtils.showNetworkErrorDialog(
                context,
                error: provider.error,
              );
            });
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '할일을 불러올 수 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '잠시 후 다시 시도해주세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('새로고침'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodoList(provider.todos),
              _buildTodoList(provider.todayTodos),
              _buildTodoList(provider.overdueTodos),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TodoAddPage(),
              ),
            );
            if (result == true) {
              _loadData();
            }
          } catch (e) {
            ErrorUtils.showNetworkErrorDialog(context, error: e);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '할일이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새로운 할일을 추가해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodoAddPage(),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('할일 추가하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return _buildTodoItem(todo);
        },
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.status == TodoStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('마감일: ${todo.dueDate.toString().split(' ')[0]}'),
            Text('우선순위: ${_getPriorityText(todo.priority)}'),
          ],
        ),
        leading: _getPriorityIcon(todo.priority),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, todo),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('상세보기'),
            ),
            const PopupMenuItem(
              value: 'complete',
              child: Text('완료'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('삭제'),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailPage(todo: todo),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
      ),
    );
  }

  Widget _getPriorityIcon(String priority) {
    IconData iconData;
    Color color;

    switch (priority) {
      case TodoPriority.high:
        iconData = Icons.arrow_upward;
        color = Colors.red;
        break;
      case TodoPriority.medium:
        iconData = Icons.remove;
        color = Colors.orange;
        break;
      case TodoPriority.low:
        iconData = Icons.arrow_downward;
        color = Colors.green;
        break;
      default:
        iconData = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case TodoPriority.high:
        return '높음';
      case TodoPriority.medium:
        return '중간';
      case TodoPriority.low:
        return '낮음';
      default:
        return '없음';
    }
  }

  Future<void> _handleMenuAction(String action, Todo todo) async {
    final todoProvider = context.read<TodoProvider>();

    try {
      switch (action) {
        case 'view':
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailPage(todo: todo),
            ),
          );
          if (result == true) {
            _loadData();
          }
          break;

        case 'complete':
          final result = await todoProvider.completeTodo(todo.id);
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('할일이 완료되었습니다.')),
            );
            _loadData();
          }
          break;

        case 'delete':
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('할일 삭제'),
              content: const Text('이 할일을 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('삭제'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            final success = await todoProvider.deleteTodo(todo.id);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('할일이 삭제되었습니다.')),
              );
              _loadData();
            }
          }
          break;
      }
    } catch (e) {
      ErrorUtils.showNetworkErrorDialog(context, error: e);
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => FilterDialog(
        initialStatus: _statusFilter,
        initialPriority: _priorityFilter,
        initialCategory: _categoryFilter,
        onFilterChanged: (status, priority, category) {
          setState(() {
            _statusFilter = status;
            _priorityFilter = priority;
            _categoryFilter = category;
          });
        },
      ),
    );

    if (result != null) {
      _loadData();
    }
  }
}

class FilterDialog extends StatefulWidget {
  final String? initialStatus;
  final String? initialPriority;
  final String? initialCategory;
  final Function(String?, String?, String?)? onFilterChanged;

  const FilterDialog({
    Key? key,
    this.initialStatus,
    this.initialPriority,
    this.initialCategory,
    this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedPriority = widget.initialPriority;
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('필터'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String?>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: '상태',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('전체')),
              DropdownMenuItem(
                value: TodoStatus.pending,
                child: const Text('대기'),
              ),
              DropdownMenuItem(
                value: TodoStatus.inProgress,
                child: const Text('진행 중'),
              ),
              DropdownMenuItem(
                value: TodoStatus.completed,
                child: const Text('완료'),
              ),
              DropdownMenuItem(
                value: TodoStatus.cancelled,
                child: const Text('취소'),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              widget.onFilterChanged?.call(
                _selectedStatus,
                _selectedPriority,
                _selectedCategory,
              );
            },
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String?>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              labelText: '우선순위',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('전체')),
              DropdownMenuItem(
                value: TodoPriority.high,
                child: const Text('높음'),
              ),
              DropdownMenuItem(
                value: TodoPriority.medium,
                child: const Text('중간'),
              ),
              DropdownMenuItem(
                value: TodoPriority.low,
                child: const Text('낮음'),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedPriority = value);
              widget.onFilterChanged?.call(
                _selectedStatus,
                _selectedPriority,
                _selectedCategory,
              );
            },
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String?>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: '카테고리',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('전체')),
              DropdownMenuItem(
                value: TodoCategory.milking,
                child: const Text('착유'),
              ),
              DropdownMenuItem(
                value: TodoCategory.healthCheck,
                child: const Text('건강검진'),
              ),
              DropdownMenuItem(
                value: TodoCategory.vaccination,
                child: const Text('백신접종'),
              ),
              DropdownMenuItem(
                value: TodoCategory.treatment,
                child: const Text('치료'),
              ),
              DropdownMenuItem(
                value: TodoCategory.breeding,
                child: const Text('번식'),
              ),
              DropdownMenuItem(
                value: TodoCategory.feeding,
                child: const Text('사료급여'),
              ),
              DropdownMenuItem(
                value: TodoCategory.facility,
                child: const Text('시설관리'),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedCategory = value);
              widget.onFilterChanged?.call(
                _selectedStatus,
                _selectedPriority,
                _selectedCategory,
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
} 