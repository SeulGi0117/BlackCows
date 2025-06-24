import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class HealthCheckAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const HealthCheckAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<HealthCheckAddPage> createState() => _HealthCheckAddPageState();
}

class _HealthCheckAddPageState extends State<HealthCheckAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _recordDateController = TextEditingController();
  final _checkTimeController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _bcsController = TextEditingController();
  final _udderController = TextEditingController();
  final _hoofController = TextEditingController();
  final _coatController = TextEditingController();
  final _eyeController = TextEditingController();
  final _noseController = TextEditingController();
  final _appetiteController = TextEditingController();
  final _activityController = TextEditingController();
  final _abnormalSymptomsController = TextEditingController();
  final _examinerController = TextEditingController();
  final _nextCheckDateController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _recordDateController.dispose();
    _checkTimeController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _bcsController.dispose();
    _udderController.dispose();
    _hoofController.dispose();
    _coatController.dispose();
    _eyeController.dispose();
    _noseController.dispose();
    _appetiteController.dispose();
    _activityController.dispose();
    _abnormalSymptomsController.dispose();
    _examinerController.dispose();
    _nextCheckDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;

      final record = HealthCheckRecord(
        id: _uuid.v4(), // 임시 UUID
        cowId: widget.cowId,
        recordDate: _recordDateController.text,
        checkTime: _checkTimeController.text,
        bodyTemperature: double.parse(_temperatureController.text),
        heartRate: int.parse(_heartRateController.text),
        respiratoryRate: int.parse(_respiratoryRateController.text),
        bodyConditionScore: double.parse(_bcsController.text),
        udderCondition: _udderController.text,
        hoofCondition: _hoofController.text,
        coatCondition: _coatController.text,
        eyeCondition: _eyeController.text,
        noseCondition: _noseController.text,
        appetite: _appetiteController.text,
        activityLevel: _activityController.text,
        abnormalSymptoms: _abnormalSymptomsController.text.split(','),
        examiner: _examinerController.text,
        nextCheckDate: _nextCheckDateController.text,
        notes: _notesController.text,
      );

      final success =
          await Provider.of<HealthCheckProvider>(context, listen: false)
              .addRecord(record, token!);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록 추가에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('건강검진 기록 추가')),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_recordDateController, '검진 날짜 (YYYY-MM-DD)'),
              _buildTextField(_checkTimeController, '검진 시간 (HH:MM:SS)'),
              _buildTextField(_temperatureController, '체온 (℃)', isNumber: true),
              _buildTextField(_heartRateController, '심박수', isNumber: true),
              _buildTextField(_respiratoryRateController, '호흡수',
                  isNumber: true),
              _buildTextField(_bcsController, '체형 점수', isNumber: true),
              _buildTextField(_udderController, '유방 상태'),
              _buildTextField(_hoofController, '발굽 상태'),
              _buildTextField(_coatController, '털 상태'),
              _buildTextField(_eyeController, '눈 상태'),
              _buildTextField(_noseController, '코 상태'),
              _buildTextField(_appetiteController, '식욕 상태'),
              _buildTextField(_activityController, '활동 수준'),
              _buildTextField(_abnormalSymptomsController, '이상 증상 (쉼표로 구분)'),
              _buildTextField(_examinerController, '검진자'),
              _buildTextField(_nextCheckDateController, '다음 검진 날짜'),
              _buildTextField(_notesController, '특이사항', maxLines: 3),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('기록 추가하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? '필수 항목입니다.' : null,
      ),
    );
  }
}
