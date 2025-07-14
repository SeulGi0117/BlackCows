import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_utils.dart';
import 'todo_add_page.dart';
import 'todo_detail_page.dart';
import '../../providers/cow_provider.dart';
import '../../models/cow.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String? _statusFilter;
  String? _priorityFilter;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _reloadAllData();
  }

  Future<void> _reloadAllData() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    final provider = context.read<TodoProvider>();
    await provider.loadTodos(status: _statusFilter);
    await provider.loadStatistics();
    await provider.loadCalendarTodos(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 관리'),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const LoadingWidget();

          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorUtils.showNetworkErrorDialog(context, error: provider.error);
              provider.clearError();
            });
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          return Column(
            children: [
              _CalendarSection(calendarTodos: provider.calendarTodos),
              const SizedBox(height: 12),
              _StatusCardSection(
                statistics: provider.statistics,
                currentStatus: provider.currentStatusFilter,
                onStatusSelected: (status) {
                  setState(() => _statusFilter = status);
                  _reloadAllData();
                },
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFilterChip(label: '상태', value: _statusFilter),
                        _buildFilterChip(label: '우선순위', value: _priorityFilter),
                        _buildFilterChip(label: '카테고리', value: _categoryFilter),
                        const Icon(Icons.filter_list),
                      ],
                    ),
                  ),
                ),
              ),

              // 할 일 리스트
              Expanded(child: _buildTodoList(provider.filteredTodos)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoAddPage()),
          );
          if (result == true) await _reloadAllData();
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
            Icon(Icons.task_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('할일이 없습니다',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('새로운 할일을 추가해보세요!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodoAddPage()),
                );
                if (result == true) await _reloadAllData();
              },
              icon: const Icon(Icons.add),
              label: const Text('할일 추가하기'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reloadAllData,
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) => _buildTodoItem(todos[index]),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    final cowProvider = context.read<CowProvider>();
    // 카테고리별 아이콘/색상 매핑
    final categoryIconMap = {
      'milking': Icons.local_drink,
      'health_check': Icons.health_and_safety,
      'vaccination': Icons.vaccines,
      'treatment': Icons.healing,
      'breeding': Icons.family_restroom,
      'feeding': Icons.restaurant,
      'facility': Icons.build,
    };
    final categoryColorMap = {
      'milking': const Color(0xFF3CB371), // 진초록
      'health_check': const Color(0xFF3A5BA0), // 파랑
      'vaccination': const Color(0xFFFFA500), // 주황
      'treatment': const Color(0xFF8A2BE2), // 보라
      'breeding': const Color(0xFF8A2BE2), // 보라
      'feeding': const Color(0xFF3CB371), // 진초록
      'facility': const Color(0xFF3A5BA0), // 파랑
    };
    final icon = categoryIconMap[todo.category] ?? Icons.task_alt;
    final iconColor =
        categoryColorMap[todo.category] ?? const Color(0xFF3A5BA0);

    // 날짜 표시 (오늘/며칠 후/며칠 전)
    final now = DateTime.now();
    final due = todo.dueDate;
    String dateLabel = '';
    bool isOverdue = false;
    bool isToday = false;

    isToday =
        due.year == now.year && due.month == now.month && due.day == now.day;
    isOverdue = due.isBefore(DateTime(now.year, now.month, now.day));

    final diff = due.difference(now).inDays;
    if (isToday) {
      dateLabel = '오늘';
    } else if (diff > 0) {
      dateLabel = '$diff일 후';
    } else if (diff < 0) {
      dateLabel = '${-diff}일 전';
    }

    // 상태 뱃지
    String? statusBadge;
    Color? statusBadgeColor;
    if (isOverdue) {
      statusBadge = '지연';
      statusBadgeColor = const Color(0xFFE57373); // 연빨강
    } else if (isToday) {
      statusBadge = '오늘';
      statusBadgeColor = const Color(0xFFFFA500); // 주황
    }
    // 우선순위 뱃지(첨부 UI)
    String? priorityBadge;
    Color? priorityBadgeColor;
    if (todo.priority == TodoPriority.high) {
      priorityBadge = '높음';
      priorityBadgeColor = const Color(0xFFFFA500); // 주황
    }

    // 소 정보 표시 (있으면)
    String? cowInfo;
    if (todo.relatedCows.isNotEmpty) {
      // relatedCows에 id만 있을 경우 이름/이표번호 찾아서 표시
      final cowId = todo.relatedCows.first;
      final cow = cowProvider.cows.firstWhere(
        (c) => c.id == cowId,
        orElse: () => Cow(
          id: cowId,
          name: '',
          earTagNumber: '',
          farmId: '',
          ownerId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
      );
      if (cow.name.isNotEmpty && cow.earTagNumber.isNotEmpty) {
        cowInfo = '${cow.name} (${cow.earTagNumber})';
      } else {
        cowInfo = cowId;
      }
    }

    return GestureDetector(
      onTap: () async {
        final action = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('수정'),
                    onTap: () => Navigator.pop(context, 'edit'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('삭제'),
                    onTap: () => Navigator.pop(context, 'delete'),
                  ),
                  if (todo.status != TodoStatus.completed)
                    ListTile(
                      leading: const Icon(Icons.check_circle),
                      title: const Text('완료'),
                      onTap: () => Navigator.pop(context, 'complete'),
                    ),
                ],
              ),
            );
          },
        );
        if (action == 'edit') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailPage(todo: todo),
            ),
          );
          if (result == true) {
            final provider = context.read<TodoProvider>();
            await provider.loadTodos(status: provider.currentStatusFilter);
            await provider.loadStatistics();
            await provider.loadCalendarTodos(
                DateTime(DateTime.now().year, DateTime.now().month, 1),
                DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
          }
        } else if (action == 'delete') {
          final provider = context.read<TodoProvider>();
          await provider.deleteTodo(todo.id);
          await provider.loadTodos(status: provider.currentStatusFilter);
          await provider.loadStatistics();
          await provider.loadCalendarTodos(
              DateTime(DateTime.now().year, DateTime.now().month, 1),
              DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
        } else if (action == 'complete') {
          final provider = context.read<TodoProvider>();
          await provider.completeTodo(todo.id);
          await provider.loadTodos(status: provider.currentStatusFilter);
          await provider.loadStatistics();
          await provider.loadCalendarTodos(
              DateTime(DateTime.now().year, DateTime.now().month, 1),
              DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E0),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 라디오 버튼(완료 처리)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Radio<bool>(
                value: true,
                groupValue: todo.status == TodoStatus.completed,
                onChanged: todo.status == TodoStatus.completed
                    ? null
                    : (val) async {
                        final provider = context.read<TodoProvider>();
                        await provider.completeTodo(todo.id);
                        await provider.loadTodos(
                            status: provider.currentStatusFilter);
                        await provider.loadStatistics();
                        await provider.loadCalendarTodos(
                            DateTime(
                                DateTime.now().year, DateTime.now().month, 1),
                            DateTime(DateTime.now().year,
                                DateTime.now().month + 1, 0));
                      },
                activeColor: const Color(0xFF3CB371),
              ),
            ),
            // 카테고리 아이콘
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFE8F7E5),
                radius: 18,
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            // 메인 정보
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                            decoration: todo.status == TodoStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (statusBadge != null)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBadgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusBadge,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  if (cowInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Text(
                        cowInfo,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (todo.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        todo.description,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        todo.dueDate != null
                            ? '${todo.dueDate.year}-${todo.dueDate.month.toString().padLeft(2, '0')}-${todo.dueDate.day.toString().padLeft(2, '0')}'
                            : '',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (dateLabel.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange),
                        ),
                      ],
                      if (priorityBadge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityBadgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priorityBadge,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

  Widget _buildFilterItem({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value ?? '전체',
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.blueGrey.shade400),
              items: options.map((opt) {
                return DropdownMenuItem(value: opt, child: Text(opt));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
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

    if (result != null) await _reloadAllData();
  }
}

Widget _buildFilterChip({required String label, String? value}) {
  final display = value ?? '전체';
  return Row(
    children: [
      Text(
        '$label: ',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        display,
        style: const TextStyle(color: Colors.black87),
      ),
    ],
  );
}

class FilterDialog extends StatefulWidget {
  final String? initialStatus;
  final String? initialPriority;
  final String? initialCategory;
  final Function(String?, String?, String?)? onFilterChanged;

  const FilterDialog({
    super.key,
    this.initialStatus,
    this.initialPriority,
    this.initialCategory,
    this.onFilterChanged,
  });

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
            items: const [
              DropdownMenuItem(value: null, child: Text('전체')),
              DropdownMenuItem(
                value: TodoStatus.pending,
                child: Text('대기'),
              ),
              DropdownMenuItem(
                value: TodoStatus.inProgress,
                child: Text('진행 중'),
              ),
              DropdownMenuItem(
                value: TodoStatus.completed,
                child: Text('완료'),
              ),
              DropdownMenuItem(
                value: TodoStatus.cancelled,
                child: Text('취소'),
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
            items: const [
              DropdownMenuItem(value: null, child: Text('전체')),
              DropdownMenuItem(
                value: TodoPriority.high,
                child: Text('높음'),
              ),
              DropdownMenuItem(
                value: TodoPriority.medium,
                child: Text('중간'),
              ),
              DropdownMenuItem(
                value: TodoPriority.low,
                child: Text('낮음'),
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
            items: const [
              DropdownMenuItem(value: null, child: Text('전체')),
              DropdownMenuItem(
                value: TodoCategory.milking,
                child: Text('착유'),
              ),
              DropdownMenuItem(
                value: TodoCategory.healthCheck,
                child: Text('건강검진'),
              ),
              DropdownMenuItem(
                value: TodoCategory.vaccination,
                child: Text('백신접종'),
              ),
              DropdownMenuItem(
                value: TodoCategory.treatment,
                child: Text('치료'),
              ),
              DropdownMenuItem(
                value: TodoCategory.breeding,
                child: Text('번식'),
              ),
              DropdownMenuItem(
                value: TodoCategory.feeding,
                child: Text('사료급여'),
              ),
              DropdownMenuItem(
                value: TodoCategory.facility,
                child: Text('시설관리'),
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

// 상단 일정 캘린더 위젯
class _CalendarSection extends StatelessWidget {
  final Map<DateTime, List<Todo>> calendarTodos;
  const _CalendarSection({required this.calendarTodos});
  @override
  Widget build(BuildContext context) {
    final items = calendarTodos.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final showItems = items.take(7).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '내 할일 캘린더',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF3A5BA0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            children: showItems.map((e) {
              final dateStr = "${e.key.month}/${e.key.day}";
              final title = e.value.isNotEmpty ? e.value.first.title : '';
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FA), // 연한 하늘색 카드 배경
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 90,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// 상태별 카드 위젯
class _StatusCardSection extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final String currentStatus;
  final void Function(String?) onStatusSelected;
  const _StatusCardSection(
      {required this.statistics,
      required this.currentStatus,
      required this.onStatusSelected});
  @override
  Widget build(BuildContext context) {
    // 첨부 이미지 기준 색상/아이콘/글씨/숫자
    final cards = [
      {
        'label': '전체',
        'status': '',
        'count': statistics['total_tasks'] ?? 0,
        'icon': Icons.assignment,
        'bgColor': const Color(0xFFE8F7E5), // 연연두
        'iconColor': const Color(0xFF3CB371), // 진초록
        'textColor': const Color(0xFF3CB371),
      },
      {
        'label': '오늘',
        'status': 'today',
        'count': statistics['today_tasks'] ?? 0,
        'icon': Icons.calendar_today,
        'bgColor': const Color(0xFFFFF6E0), // 연노랑/연주황
        'iconColor': const Color(0xFFFFA500), // 주황
        'textColor': const Color(0xFFFFA500),
      },
      {
        'label': '대기',
        'status': 'pending',
        'count': statistics['pending_tasks'] ?? 0,
        'icon': Icons.assignment_late,
        'bgColor': const Color(0xFFE6F0FA), // 연파랑
        'iconColor': const Color(0xFF3A5BA0), // 파랑
        'textColor': const Color(0xFF3A5BA0),
      },
      {
        'label': '완료',
        'status': 'completed',
        'count': statistics['completed_tasks'] ?? 0,
        'icon': Icons.check_circle,
        'bgColor': const Color(0xFFF1E6FA), // 연보라
        'iconColor': const Color(0xFF8A2BE2), // 보라
        'textColor': const Color(0xFF8A2BE2),
      },
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: SizedBox(
        height: 130,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: cards.map((card) {
            final isSelected = currentStatus == card['status'];
            return Expanded(
              child: GestureDetector(
                onTap: () => onStatusSelected(card['status'] == 'today'
                    ? null
                    : card['status'] as String?),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                    color: card['bgColor'],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            isSelected ? card['iconColor'] : Colors.transparent,
                        width: 2),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: (card['iconColor'] as Color).withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(card['icon'], color: card['iconColor'], size: 26),
                      const SizedBox(height: 4),
                      Text('${card['count']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: card['textColor'])),
                      const SizedBox(height: 2),
                      Text(card['label']!,
                          style: TextStyle(
                              fontSize: 14,
                              color: card['textColor'],
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
