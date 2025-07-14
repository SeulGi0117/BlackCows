// pregnancy_check_add_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/pregnancy_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class PregnancyCheckAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const PregnancyCheckAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<PregnancyCheckAddPage> createState() => _PregnancyCheckAddPageState();
}

class _PregnancyCheckAddPageState extends State<PregnancyCheckAddPage> {
  final _formKey = GlobalKey<FormState>();

  final _recordDateController = TextEditingController();
  final _expectedCalvingDateController = TextEditingController();
  final _nextCheckDateController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _fetusConditionController = TextEditingController();
  final _pregnancyStageController = TextEditingController();
  final _checkCostController = TextEditingController();
  final _notesController = TextEditingController();

  String _checkMethod = '초음파';
  String _checkResult = '임신';

  final List<String> _methodOptions = ['직장검사', '초음파', '혈액검사'];
  final List<String> _resultOptions = ['임신', '비임신', '의심'];

  @override
  void initState() {
    super.initState();
    _recordDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    _expectedCalvingDateController.dispose();
    _nextCheckDateController.dispose();
    _veterinarianController.dispose();
    _fetusConditionController.dispose();
    _pregnancyStageController.dispose();
    _checkCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 임신감정 기록 추가'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateField(_recordDateController, '감정일'),
              const SizedBox(height: 16),
              _buildDropdownField('감정 방법', _checkMethod, _methodOptions,
                  (value) {
                setState(() => _checkMethod = value!);
              }),
              const SizedBox(height: 16),
              _buildDropdownField('감정 결과', _checkResult, _resultOptions,
                  (value) {
                setState(() => _checkResult = value!);
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pregnancyStageController,
                decoration: const InputDecoration(
                  labelText: '임신 단계 (일)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fetusConditionController,
                decoration: const InputDecoration(
                  labelText: '태아 상태',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildDateField(_expectedCalvingDateController, '분만 예정일'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _veterinarianController,
                decoration: const InputDecoration(
                  labelText: '수의사명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _checkCostController,
                decoration: const InputDecoration(
                  labelText: '감정 비용 (원)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDateField(_nextCheckDateController, '다음 감정일'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '메모',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = date.toString().split(' ')[0];
        }
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('임신감정 기록 저장'),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final token =
            Provider.of<UserProvider>(context, listen: false).accessToken;

        final record = PregnancyCheckRecord(
          cowId: widget.cowId,
          recordDate: _recordDateController.text,
          checkMethod: _checkMethod,
          checkResult: _checkResult,
          pregnancyStage: int.tryParse(_pregnancyStageController.text) ?? 0,
          fetusCondition: _fetusConditionController.text,
          expectedCalvingDate: _expectedCalvingDateController.text,
          veterinarian: _veterinarianController.text,
          checkCost: double.tryParse(_checkCostController.text) ?? 0.0,
          nextCheckDate: _nextCheckDateController.text,
          additionalCare: '',
          notes: _notesController.text,
        );

        await Provider.of<PregnancyCheckProvider>(context, listen: false)
            .addRecord(record, token!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('임신감정 기록이 저장되었습니다'),
                backgroundColor: Colors.pink),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
