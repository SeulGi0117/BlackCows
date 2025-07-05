import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class HealthEditPage extends StatefulWidget {
  final HealthCheckRecord record;

  const HealthEditPage({super.key, required this.record});

  @override
  State<HealthEditPage> createState() => _HealthEditPageState();
}

class _HealthEditPageState extends State<HealthEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late TextEditingController _dateController;
  late TextEditingController _checkTimeController;
  late TextEditingController _examinerController;
  late TextEditingController _temperatureController;
  late TextEditingController _heartRateController;
  late TextEditingController _respiratoryRateController;
  late TextEditingController _bcsController;
  late TextEditingController _udderController;
  late TextEditingController _eyeController;
  late TextEditingController _noseController;
  late TextEditingController _coatController;
  late TextEditingController _hoofController;
  late TextEditingController _activityController;
  late TextEditingController _appetiteController;
  late TextEditingController _symptomsController;
  late TextEditingController _nextDateController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _dateController = TextEditingController(text: r.recordDate ?? '');
    _checkTimeController = TextEditingController(text: r.checkTime ?? '');
    _examinerController = TextEditingController(text: r.examiner ?? '');
    _temperatureController =
        TextEditingController(text: r.bodyTemperature.toString() ?? '');
    _heartRateController =
        TextEditingController(text: r.heartRate.toString() ?? '');
    _respiratoryRateController =
        TextEditingController(text: r.respiratoryRate.toString() ?? '');
    _bcsController =
        TextEditingController(text: r.bodyConditionScore.toString() ?? '');
    _udderController = TextEditingController(text: r.udderCondition ?? '');
    _eyeController = TextEditingController(text: r.eyeCondition ?? '');
    _noseController = TextEditingController(text: r.noseCondition ?? '');
    _coatController = TextEditingController(text: r.coatCondition ?? '');
    _hoofController = TextEditingController(text: r.hoofCondition ?? '');
    _activityController = TextEditingController(text: r.activityLevel ?? '');
    _appetiteController = TextEditingController(text: r.appetite ?? '');
    _symptomsController =
        TextEditingController(text: r.abnormalSymptoms.join(', '));
    _nextDateController = TextEditingController(text: r.nextCheckDate ?? '');
    _notesController = TextEditingController(text: r.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _dateController,
      _checkTimeController,
      _examinerController,
      _temperatureController,
      _heartRateController,
      _respiratoryRateController,
      _bcsController,
      _udderController,
      _eyeController,
      _noseController,
      _coatController,
      _hoofController,
      _activityController,
      _appetiteController,
      _symptomsController,
      _nextDateController,
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
      'check_time': _checkTimeController.text,
      'examiner': _examinerController.text,
      'body_temperature': double.tryParse(_temperatureController.text),
      'heart_rate': int.tryParse(_heartRateController.text),
      'respiratory_rate': int.tryParse(_respiratoryRateController.text),
      'body_condition_score': double.tryParse(_bcsController.text),
      'udder_condition': _udderController.text,
      'eye_condition': _eyeController.text,
      'nose_condition': _noseController.text,
      'coat_condition': _coatController.text,
      'hoof_condition': _hoofController.text,
      'activity_level': _activityController.text,
      'appetite': _appetiteController.text,
      'abnormal_symptoms':
          _symptomsController.text.split(',').map((e) => e.trim()).toList(),
      'next_check_date': _nextDateController.text,
      'notes': _notesController.text,
    };

    final updatedData = {
      'record_date': _dateController.text,
      'record_data': recordData,
    };

    final token = context.read<UserProvider>().accessToken;
    final provider = context.read<HealthCheckProvider>();

    final success =
        await provider.updateRecord(widget.record.id!, updatedData, token!);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('건강검진 기록이 수정되었습니다')),
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
        title: const Text('건강검진 기록 수정'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('검진일 (YYYY-MM-DD)', _dateController),
              _buildField('검진 시간', _checkTimeController),
              _buildField('검진자', _examinerController),
              _buildField('체온 (℃)', _temperatureController,
                  inputType: TextInputType.number),
              _buildField('심박수', _heartRateController,
                  inputType: TextInputType.number),
              _buildField('호흡수', _respiratoryRateController,
                  inputType: TextInputType.number),
              _buildField('체형점수 (BCS)', _bcsController,
                  inputType: TextInputType.number),
              _buildField('유방 상태', _udderController),
              _buildField('눈 상태', _eyeController),
              _buildField('코 상태', _noseController),
              _buildField('털 상태', _coatController),
              _buildField('발굽 상태', _hoofController),
              _buildField('활동 수준', _activityController),
              _buildField('식욕 수준', _appetiteController),
              _buildField('이상 증상 (콤마로 구분)', _symptomsController),
              _buildField('다음 검진일', _nextDateController),
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
