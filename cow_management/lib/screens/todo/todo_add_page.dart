import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_utils.dart';
import '../../providers/cow_provider.dart';
import '../../models/cow.dart';
import '../../providers/user_provider.dart';

class TodoAddPage extends StatefulWidget {
  const TodoAddPage({Key? key}) : super(key: key);

  @override
  State<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = TodoPriority.medium;
  String _selectedCategory = TodoCategory.milking;
  final List<String> _selectedTags = [];
  final List<String> _selectedCows = [];
  Cow? _selectedCow;
  List<Cow> _cowList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 실제 젖소 목록 불러오기
    Future.microtask(() async {
      final cowProvider = context.read<CowProvider>();
      await cowProvider.fetchCowsFromBackend(context.read<UserProvider>().accessToken ?? '');
      setState(() {
        _cowList = cowProvider.cows;
      });
    });
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
      initialDate: _selectedDate ?? DateTime.now(),
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
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마감일을 선택해주세요')),
      );
      return;
    }
    if (_selectedPriority.isEmpty || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('우선순위와 카테고리를 선택해주세요')),
      );
      return;
    }

    _formKey.currentState!.save();
    
    try {
      final todoProvider = context.read<TodoProvider>();
      final success = await todoProvider.createTodo({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'due_date': _selectedDate!.toIso8601String().split('T')[0],
        'due_time': _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'priority': _selectedPriority,
        'category': _selectedCategory,
        'status': TodoStatus.pending,
        'task_type': 'personal',
        if (_selectedCow != null) 'related_cows': [_selectedCow!.id],
      });

      if (success != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('할일이 추가되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // ErrorUtils.showNetworkErrorDialog(context, error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요.')),
        );
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
        title: const Text('할일 추가'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTodo,
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
              subtitle: Text(_selectedDate == null
                  ? '선택해주세요'
                  : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'),
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
            DropdownButtonFormField<Cow>(
              value: _selectedCow,
              decoration: const InputDecoration(
                labelText: '소 선택',
                border: OutlineInputBorder(),
              ),
              items: _cowList.map((cow) => DropdownMenuItem(
                value: cow,
                child: Text('${cow.name} (${cow.earTagNumber})'),
              )).toList(),
              onChanged: (value) {
                setState(() => _selectedCow = value);
              },
            ),
          ],
        ),
      ),
    );
  }
} 