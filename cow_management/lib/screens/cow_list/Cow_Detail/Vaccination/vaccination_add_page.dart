import 'package:flutter/material.dart';

class VaccinationAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const VaccinationAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<VaccinationAddPage> createState() => _VaccinationAddPageState();
}

class _VaccinationAddPageState extends State<VaccinationAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _vaccinationDateController =
      TextEditingController();
  final TextEditingController _nextVaccinationDateController =
      TextEditingController();
  final TextEditingController _administeredByController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      controller.text = date.toIso8601String().split('T').first;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newRecord = {
        'cow_id': widget.cowId,
        'vaccine_name': _vaccineNameController.text,
        'vaccination_date': _vaccinationDateController.text,
        'next_vaccination_date': _nextVaccinationDateController.text,
        'administered_by': _administeredByController.text,
        'notes': _notesController.text,
      };

      print('✅ 등록된 백신 정보: $newRecord');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('백신 접종 기록 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _vaccineNameController,
                decoration: const InputDecoration(labelText: '백신 이름'),
                validator: (value) => value!.isEmpty ? '백신 이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _vaccinationDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: '접종일자'),
                onTap: () => _selectDate(_vaccinationDateController),
                validator: (value) => value!.isEmpty ? '접종일자를 입력하세요' : null,
              ),
              TextFormField(
                controller: _nextVaccinationDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: '다음 접종일자'),
                onTap: () => _selectDate(_nextVaccinationDateController),
              ),
              TextFormField(
                controller: _administeredByController,
                decoration: const InputDecoration(labelText: '시행자'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: '비고'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('기록 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
