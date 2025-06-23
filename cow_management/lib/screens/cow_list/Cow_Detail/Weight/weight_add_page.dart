import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';
import 'package:cow_management/providers/DetailPage/Health/weight_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class WeightAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const WeightAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<WeightAddPage> createState() => _WeightAddPageState();
}

class _WeightAddPageState extends State<WeightAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _bcsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;

    final newRecord = WeightRecord(
      cowId: widget.cowId,
      recordDate: _dateController.text,
      weight: double.tryParse(_weightController.text),
      measurementMethod: _methodController.text,
      bodyConditionScore: double.tryParse(_bcsController.text),
      notes: _notesController.text,
    );

    try {
      await Provider.of<WeightRecordProvider>(context, listen: false)
          .addRecord(newRecord, token!);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} 체중 기록 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration:
                    const InputDecoration(labelText: '측정일 (YYYY-MM-DD)'),
                validator: (value) => value!.isEmpty ? '측정일을 입력하세요' : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: '체중 (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _methodController,
                decoration: const InputDecoration(labelText: '측정 방법'),
              ),
              TextFormField(
                controller: _bcsController,
                decoration: const InputDecoration(labelText: '체형 점수 (1~5)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: '특이사항'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? '저장 중...' : '저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
