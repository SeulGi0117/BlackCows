import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/pregnancy_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class PregnancyCheckEditPage extends StatefulWidget {
  final PregnancyCheckRecord record;

  const PregnancyCheckEditPage({super.key, required this.record});

  @override
  State<PregnancyCheckEditPage> createState() => _PregnancyCheckEditPageState();
}

class _PregnancyCheckEditPageState extends State<PregnancyCheckEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final TextEditingController _recordDateController;
  late final TextEditingController _checkMethodController;
  late final TextEditingController _checkResultController;
  late final TextEditingController _pregnancyStageController;
  late final TextEditingController _fetusConditionController;
  late final TextEditingController _expectedCalvingDateController;
  late final TextEditingController _veterinarianController;
  late final TextEditingController _checkCostController;
  late final TextEditingController _nextCheckDateController;
  late final TextEditingController _additionalCareController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _recordDateController = TextEditingController(text: r.recordDate);
    _checkMethodController = TextEditingController(text: r.checkMethod);
    _checkResultController = TextEditingController(text: r.checkResult);
    _pregnancyStageController =
        TextEditingController(text: r.pregnancyStage.toString());
    _fetusConditionController = TextEditingController(text: r.fetusCondition);
    _expectedCalvingDateController =
        TextEditingController(text: r.expectedCalvingDate);
    _veterinarianController = TextEditingController(text: r.veterinarian);
    _checkCostController = TextEditingController(text: r.checkCost.toString());
    _nextCheckDateController = TextEditingController(text: r.nextCheckDate);
    _additionalCareController = TextEditingController(text: r.additionalCare);
    _notesController = TextEditingController(text: r.notes);
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    _checkMethodController.dispose();
    _checkResultController.dispose();
    _pregnancyStageController.dispose();
    _fetusConditionController.dispose();
    _expectedCalvingDateController.dispose();
    _veterinarianController.dispose();
    _checkCostController.dispose();
    _nextCheckDateController.dispose();
    _additionalCareController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<PregnancyCheckProvider>();

    final recordData = {
      'check_method': _checkMethodController.text,
      'check_result': _checkResultController.text,
      'pregnancy_stage': int.tryParse(_pregnancyStageController.text) ?? 0,
      'fetus_condition': _fetusConditionController.text,
      'expected_calving_date': _expectedCalvingDateController.text,
      'veterinarian': _veterinarianController.text,
      'check_cost': double.tryParse(_checkCostController.text) ?? 0.0,
      'next_check_date': _nextCheckDateController.text,
      'additional_care': _additionalCareController.text,
      'notes': _notesController.text,
    };

    final updatedData = {
      'record_date': _recordDateController.text,
      'record_data': recordData,
    };

    try {
      final success =
          await provider.updateRecord(widget.record.id!, updatedData, token);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류 발생: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '필수 입력 항목입니다.';
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller),
          ),
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('임신감정 기록 수정'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDateField('감정일', _recordDateController),
              _buildTextField('감정 방법', _checkMethodController),
              _buildTextField('감정 결과', _checkResultController),
              _buildTextField('임신 주차', _pregnancyStageController,
                  isNumber: true),
              _buildTextField('태아 상태', _fetusConditionController),
              _buildDateField('분만 예정일', _expectedCalvingDateController),
              _buildTextField('수의사명', _veterinarianController),
              _buildTextField('감정 비용', _checkCostController, isNumber: true),
              _buildDateField('다음 감정일', _nextCheckDateController),
              _buildTextField('추가 관리사항', _additionalCareController),
              _buildTextField('비고', _notesController, maxLines: 3),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('기록 수정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
