import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/vaccination_record_provider.dart';

class VaccinationEditPage extends StatefulWidget {
  final VaccinationRecord record;

  const VaccinationEditPage({super.key, required this.record});

  @override
  State<VaccinationEditPage> createState() => _VaccinationEditPageState();
}

class _VaccinationEditPageState extends State<VaccinationEditPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = {
      'record_date': widget.record.recordDate,
      'vaccination_time': widget.record.vaccinationTime ?? '',
      'administrator': widget.record.administrator ?? '',
      'vaccine_name': widget.record.vaccineName ?? '',
      'vaccine_type': widget.record.vaccineType ?? '',
      'vaccine_manufacturer': widget.record.vaccineManufacturer ?? '',
      'vaccine_batch': widget.record.vaccineBatch ?? '',
      'expiry_date': widget.record.expiryDate ?? '',
      'dosage': widget.record.dosage?.toString() ?? '',
      'injection_site': widget.record.injectionSite ?? '',
      'injection_method': widget.record.injectionMethod ?? '',
      'adverse_reaction': widget.record.adverseReaction?.toString() ?? 'false',
      'reaction_details': widget.record.reactionDetails ?? '',
      'next_vaccination_due': widget.record.nextVaccinationDue ?? '',
      'cost': widget.record.cost?.toString() ?? '',
      'notes': widget.record.notes ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('백신접종 수정'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._buildFormFields(), // FormField 위젯들 펼치기
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('수정 완료', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    List<Widget> widgets = fields.map((field) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: _formData[field['key']] ?? '',
          decoration: InputDecoration(
            labelText: field['label'],
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _formData[field['key']!] = value,
        ),
      );
    }).toList();

    // 여기서 명시적으로 추가!
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SwitchListTile(
          title: const Text('부작용 발생 여부'),
          value: _formData['adverse_reaction'] == 'true',
          onChanged: (value) {
            setState(() {
              _formData['adverse_reaction'] = value.toString();
            });
          },
        ),
      ),
    );

    return widgets;
  }

  final List<Map<String, String>> fields = [
    {'key': 'record_date', 'label': '기록 날짜 (YYYY-MM-DD)'},
    {'key': 'vaccination_time', 'label': '접종 시간'},
    {'key': 'administrator', 'label': '접종자'},
    {'key': 'vaccine_name', 'label': '백신 이름'},
    {'key': 'vaccine_type', 'label': '백신 종류'},
    {'key': 'vaccine_manufacturer', 'label': '백신 제조사'},
    {'key': 'vaccine_batch', 'label': '백신 배치 번호'},
    {'key': 'expiry_date', 'label': '유효 기간 (YYYY-MM-DD)'},
    {'key': 'dosage', 'label': '용량 (ml)'},
    {'key': 'injection_site', 'label': '접종 부위'},
    {'key': 'injection_method', 'label': '접종 방법'},
    {'key': 'reaction_details', 'label': '부작용 상세 정보'},
    {'key': 'next_vaccination_due', 'label': '다음 접종 예정일 (YYYY-MM-DD)'},
    {'key': 'cost', 'label': '비용 (원)'},
    {'key': 'notes', 'label': '메모'},
  ];
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<VaccinationRecordProvider>();

    final recordId = widget.record.id!;
    final updatedData = {
      'record_date': _formData['record_date'],
      'title': '백신접종',
      'description': '',
      'record_data': {
        ..._formData,
        'dosage': double.tryParse(_formData['dosage'] ?? ''),
        'cost': double.tryParse(_formData['cost'] ?? ''),
        'adverse_reaction': _formData['adverse_reaction'] == 'true',
      }
    };

    final success = await provider.updateRecord(recordId, updatedData, token);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정 완료되었습니다')),
      );
      Navigator.of(context).pop(true); // 돌아가기
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정에 실패했습니다')),
      );
    }
  }
}
