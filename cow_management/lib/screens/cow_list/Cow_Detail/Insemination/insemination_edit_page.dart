import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/insemination_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class InseminationEditPage extends StatefulWidget {
  final InseminationRecord record;

  const InseminationEditPage({super.key, required this.record});

  @override
  State<InseminationEditPage> createState() => _InseminationEditPageState();
}

class _InseminationEditPageState extends State<InseminationEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _bullIdController;
  late TextEditingController _bullBreedController;
  late TextEditingController _semenBatchController;
  late TextEditingController _semenQualityController;
  late TextEditingController _methodController;
  late TextEditingController _technicianController;
  late TextEditingController _cervixController;
  late TextEditingController _successController;
  late TextEditingController _pregnancyCheckController;
  late TextEditingController _costController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _dateController = TextEditingController(text: r.recordDate);
    _timeController = TextEditingController(text: r.inseminationTime ?? '');
    _bullIdController = TextEditingController(text: r.bullId ?? '');
    _bullBreedController = TextEditingController(text: r.bullBreed ?? '');
    _semenBatchController = TextEditingController(text: r.semenBatch ?? '');
    _semenQualityController = TextEditingController(text: r.semenQuality ?? '');
    _methodController = TextEditingController(text: r.inseminationMethod ?? '');
    _technicianController = TextEditingController(text: r.technicianName ?? '');
    _cervixController = TextEditingController(text: r.cervixCondition ?? '');
    _successController = TextEditingController(
        text: r.successProbability?.toStringAsFixed(1) ?? '');
    _pregnancyCheckController =
        TextEditingController(text: r.pregnancyCheckScheduled ?? '');
    _costController =
        TextEditingController(text: r.cost?.toStringAsFixed(0) ?? '');
    _notesController = TextEditingController(text: r.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _dateController,
      _timeController,
      _bullIdController,
      _bullBreedController,
      _semenBatchController,
      _semenQualityController,
      _methodController,
      _technicianController,
      _cervixController,
      _successController,
      _pregnancyCheckController,
      _costController,
      _notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final recordData = {
      'insemination_time': _timeController.text,
      'bull_id': _bullIdController.text,
      'bull_breed': _bullBreedController.text,
      'semen_batch': _semenBatchController.text,
      'semen_quality': _semenQualityController.text,
      'insemination_method': _methodController.text,
      'technician_name': _technicianController.text,
      'cervix_condition': _cervixController.text,
      'success_probability':
          double.tryParse(_successController.text.replaceAll('%', '')),
      'pregnancy_check_scheduled': _pregnancyCheckController.text,
      'cost': double.tryParse(_costController.text),
      'notes': _notesController.text,
    };

    final updatedData = {
      'record_date': _dateController.text,
      'record_data': recordData,
    };

    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<InseminationRecordProvider>();

    final success =
        await provider.updateRecord(widget.record.id!, updatedData, token);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록이 수정되었습니다')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정 실패'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: inputType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인공수정 기록 수정'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('수정일 (YYYY-MM-DD)', _dateController),
              _buildField('수정 시간', _timeController),
              _buildField('종축 ID', _bullIdController),
              _buildField('종축 품종', _bullBreedController),
              _buildField('정액 배치 번호', _semenBatchController),
              _buildField('정액 품질', _semenQualityController),
              _buildField('수정 방법', _methodController),
              _buildField('수의사 이름', _technicianController),
              _buildField('자궁경부 상태', _cervixController),
              _buildField('성공 확률 (%)', _successController,
                  inputType: TextInputType.number),
              _buildField('임신감정 예정일', _pregnancyCheckController),
              _buildField('비용 (숫자만)', _costController,
                  inputType: TextInputType.number),
              _buildField('특이사항', _notesController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('저장'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
