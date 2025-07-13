import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_utils.dart';

class TodoDetailPage extends StatefulWidget {
  final Todo todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay? _selectedTime;
  late String _selectedPriority;
  late String _selectedCategory;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description);
    _selectedDate = widget.todo.dueDate ?? DateTime.now();
    _selectedTime = widget.todo.dueTime;
    _selectedPriority = widget.todo.priority;
    _selectedCategory = widget.todo.category;
    _selectedStatus = widget.todo.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final todoProvider = context.read<TodoProvider>();
      final updatedTodo = widget.todo.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        priority: _selectedPriority,
        category: _selectedCategory,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      final todo = await todoProvider.updateTodo(widget.todo.id, updatedTodo);
      if (todo != null && mounted)
        Navigator.pop(context, true);
      else
        _showErrorSnackBar('수정에 실패했습니다');
    } catch (e) {
      _showErrorSnackBar('에러 발생: $e');
    }
  }

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할일 삭제'),
        content: const Text('이 할일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final todoProvider = context.read<TodoProvider>();
        final success = await todoProvider.deleteTodo(widget.todo.id);
        if (success && mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) ErrorUtils.showNetworkErrorDialog(context, error: e);
      }
    }
  }

  Future<void> _completeTodo() async {
    try {
      final todoProvider = context.read<TodoProvider>();
      final result = await todoProvider.completeTodo(widget.todo.id);
      if (result != null && mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ErrorUtils.showNetworkErrorDialog(context, error: e);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 상세'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTodo),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTodo),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextField(_titleController, '제목', true),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, '설명', false),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 16),
            _buildDropdownField(
                '우선순위',
                _selectedPriority,
                [
                  TodoPriority.high,
                  TodoPriority.medium,
                  TodoPriority.low,
                ],
                (val) => setState(() => _selectedPriority = val)),
            const SizedBox(height: 16),
            _buildDropdownField(
                '카테고리',
                _selectedCategory,
                [
                  TodoCategory.milking,
                  TodoCategory.healthCheck,
                  TodoCategory.vaccination,
                  TodoCategory.treatment,
                  TodoCategory.breeding,
                  TodoCategory.feeding,
                  TodoCategory.facility,
                ],
                (val) => setState(() => _selectedCategory = val)),
            const SizedBox(height: 16),
            _buildDropdownField(
                '상태',
                _selectedStatus,
                [
                  TodoStatus.pending,
                  TodoStatus.inProgress,
                  TodoStatus.completed,
                  TodoStatus.cancelled,
                  TodoStatus.overdue,
                ],
                (val) => setState(() => _selectedStatus = val)),
          ],
        ),
      ),
      floatingActionButton: widget.todo.status != TodoStatus.completed
          ? FloatingActionButton.extended(
              onPressed: _completeTodo,
              icon: const Icon(Icons.check),
              label: const Text('완료'),
            )
          : null,
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      maxLines: label == '설명' ? 3 : 1,
      validator: isRequired
          ? (value) =>
              (value == null || value.isEmpty) ? '$label을 입력해주세요' : null
          : null,
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('마감일'),
          subtitle: Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: _selectDate,
        ),
        ListTile(
          title: const Text('마감 시간'),
          subtitle: Text(_selectedTime == null
              ? '선택해주세요'
              : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.access_time),
          onTap: _selectTime,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options
          .map((opt) =>
              DropdownMenuItem(value: opt, child: Text(_mapLabel(opt))))
          .toList(),
      onChanged: (val) => val != null ? onChanged(val) : null,
    );
  }

  String _mapLabel(String value) {
    const map = {
      TodoPriority.high: '높음',
      TodoPriority.medium: '중간',
      TodoPriority.low: '낮음',
      TodoCategory.milking: '착유',
      TodoCategory.healthCheck: '건강검진',
      TodoCategory.vaccination: '백신접종',
      TodoCategory.treatment: '치료',
      TodoCategory.breeding: '번식',
      TodoCategory.feeding: '사료급여',
      TodoCategory.facility: '시설관리',
      TodoStatus.pending: '대기',
      TodoStatus.inProgress: '진행 중',
      TodoStatus.completed: '완료',
      TodoStatus.cancelled: '취소',
      TodoStatus.overdue: '지연',
    };
    return map[value] ?? value;
  }
}
