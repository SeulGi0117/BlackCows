import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_utils.dart';

class TodoDetailPage extends StatefulWidget {
  final Todo todo;

  const TodoDetailPage({Key? key, required this.todo}) : super(key: key);

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  bool _isLoading = false;
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
    _descriptionController = TextEditingController(text: widget.todo.description);
    _selectedDate = widget.todo.dueDate;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    
    try {
      final todoProvider = context.read<TodoProvider>();
      final todo = await todoProvider.updateTodo(
        widget.todo.id,
        {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'due_date': _selectedDate.toIso8601String().split('T')[0],
          'due_time': _selectedTime != null
              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : null,
          'priority': _selectedPriority,
          'category': _selectedCategory,
        },
      );

      if (todo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('할일이 수정되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorUtils.showNetworkErrorDialog(context, error: e);
      }
    }
  }

  Future<void> _deleteTodo() async {
    try {
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
        final todoProvider = context.read<TodoProvider>();
        final success = await todoProvider.deleteTodo(widget.todo.id);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('할일이 삭제되었습니다.')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorUtils.showNetworkErrorDialog(context, error: e);
      }
    }
  }

  Future<void> _completeTodo() async {
    try {
      final todoProvider = context.read<TodoProvider>();
      final result = await todoProvider.completeTodo(widget.todo.id);
      
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('할일이 완료되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorUtils.showNetworkErrorDialog(context, error: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTodo,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTodo,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text('마감일'),
              subtitle: Text('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('마감 시간'),
              subtitle: Text(_selectedTime == null
                  ? '선택해주세요'
                  : '${_selectedTime!.hour}:${_selectedTime!.minute}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: '우선순위',
                border: OutlineInputBorder(),
              ),
              items: [
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
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: [
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
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '상태',
                border: OutlineInputBorder(),
              ),
              items: [
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
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
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
} 