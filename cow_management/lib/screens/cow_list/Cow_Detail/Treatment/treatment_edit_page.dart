import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class TreatmentEditPage extends StatefulWidget {
  final TreatmentRecord record;

  const TreatmentEditPage({super.key, required this.record});

  @override
  State<TreatmentEditPage> createState() => _TreatmentEditPageState();
}

class _TreatmentEditPageState extends State<TreatmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = {
      'record_date': widget.record.recordDate,
      'treatment_time': widget.record.treatmentTime ?? '',
      'treatment_type': widget.record.treatmentType ?? '',
      'diagnosis': widget.record.diagnosis ?? '',
      'symptoms': widget.record.symptoms?.join(', ') ?? '',
      'medication_used': widget.record.medicationUsed?.join(', ') ?? '',
      'treatment_method': widget.record.treatmentMethod ?? '',
      'treatment_duration': widget.record.treatmentDuration?.toString() ?? '',
      'withdrawal_period': widget.record.withdrawalPeriod?.toString() ?? '',
      'veterinarian': widget.record.veterinarian ?? '',
      'treatment_cost': widget.record.treatmentCost?.toString() ?? '',
      'treatment_response': widget.record.treatmentResponse ?? '',
      'side_effects': widget.record.sideEffects ?? '',
      'follow_up_required':
          widget.record.followUpRequired?.toString() ?? 'false',
      'follow_up_date': widget.record.followUpDate ?? '',
      'notes': widget.record.notes ?? '',
    };
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final token = context.read<UserProvider>().accessToken!;
      final provider = context.read<TreatmentRecordProvider>();

      final updatedData = Map<String, dynamic>.from(_formData);
      updatedData['symptoms'] =
          _formData['symptoms'].split(',').map((e) => e.trim()).toList();
      updatedData['medication_used'] =
          _formData['medication_used'].split(',').map((e) => e.trim()).toList();
      updatedData['treatment_duration'] =
          int.tryParse(_formData['treatment_duration'] ?? '') ?? 0;
      updatedData['withdrawal_period'] =
          int.tryParse(_formData['withdrawal_period'] ?? '') ?? 0;
      updatedData['treatment_cost'] =
          int.tryParse(_formData['treatment_cost'] ?? '') ?? 0;
      updatedData['follow_up_required'] =
          _formData['follow_up_required'] == 'true';

      final success =
          await provider.updateRecord(widget.record.id!, updatedData, token);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정 완료되었습니다')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정에 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('치료 기록 수정'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ..._buildTextFormFields(),
              SwitchListTile(
                title: const Text('추가 치료 필요 여부'),
                value: _formData['follow_up_required'] == 'true',
                onChanged: (val) => setState(() {
                  _formData['follow_up_required'] = val.toString();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextFormFields() {
    final fields = [
      {'label': '치료일', 'key': 'record_date'},
      {'label': '치료 시간', 'key': 'treatment_time'},
      {'label': '치료 유형', 'key': 'treatment_type'},
      {'label': '진단명', 'key': 'diagnosis'},
      {'label': '증상 (쉼표 구분)', 'key': 'symptoms'},
      {'label': '사용 약물 (쉼표 구분)', 'key': 'medication_used'},
      {'label': '치료 방법', 'key': 'treatment_method'},
      {'label': '치료 기간(일)', 'key': 'treatment_duration'},
      {'label': '휴약기간(일)', 'key': 'withdrawal_period'},
      {'label': '담당 수의사', 'key': 'veterinarian'},
      {'label': '치료 비용(원)', 'key': 'treatment_cost'},
      {'label': '치료 반응', 'key': 'treatment_response'},
      {'label': '부작용', 'key': 'side_effects'},
      {'label': '추가 치료일', 'key': 'follow_up_date'},
      {'label': '특이사항', 'key': 'notes'},
    ];

    return fields
        .map(
          (field) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              initialValue: _formData[field['key']] ?? '',
              decoration: InputDecoration(
                labelText: field['label'],
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => _formData[field['key']!] = val,
            ),
          ),
        )
        .toList();
  }
}
