import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final Map<String, dynamic> _formData = {
    'record_date': '',
    'vaccination_time': '',
    'vaccine_name': '',
    'vaccine_type': '',
    'vaccine_batch': '',
    'dosage': '',
    'injection_site': '',
    'injection_method': '',
    'administrator': '',
    'vaccine_manufacturer': '',
    'expiry_date': '',
    'adverse_reaction': false,
    'reaction_details': '',
    'next_vaccination_due': '',
    'cost': '',
    'notes': '',
  };

  Future<void> _pickDate(String key) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _formData[key] = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime(String key) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final time = picked.format(context);
        _formData[key] = time;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final record = {
        'cow_id': widget.cowId,
        ..._formData,
        'dosage': double.tryParse(_formData['dosage']),
        'cost': int.tryParse(_formData['cost']),
      };
      print('✅ 등록된 백신 정보: $record');
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(String label, String key,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onChanged: (value) => _formData[key] = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} 백신 기록 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: () => _pickDate('record_date'),
                child: Text(_formData['record_date'].isEmpty
                    ? '접종일자 선택'
                    : '접종일자: ${_formData['record_date']}'),
              ),
              ElevatedButton(
                onPressed: () => _pickTime('vaccination_time'),
                child: Text(_formData['vaccination_time'].isEmpty
                    ? '접종 시간 선택'
                    : '접종 시간: ${_formData['vaccination_time']}'),
              ),
              _buildTextField('백신 이름', 'vaccine_name'),
              _buildTextField('백신 종류', 'vaccine_type'),
              _buildTextField('백신 로트번호', 'vaccine_batch'),
              _buildTextField('접종량 (ml)', 'dosage',
                  keyboardType: TextInputType.number),
              _buildTextField('접종 부위', 'injection_site'),
              _buildTextField('접종 방법', 'injection_method'),
              _buildTextField('접종자', 'administrator'),
              _buildTextField('백신 제조사', 'vaccine_manufacturer'),
              ElevatedButton(
                onPressed: () => _pickDate('expiry_date'),
                child: Text(_formData['expiry_date'].isEmpty
                    ? '백신 유효기간 선택'
                    : '유효기간: ${_formData['expiry_date']}'),
              ),
              SwitchListTile(
                title: const Text('부작용 발생 여부'),
                value: _formData['adverse_reaction'],
                onChanged: (value) =>
                    setState(() => _formData['adverse_reaction'] = value),
              ),
              _buildTextField('부작용 상세 내용', 'reaction_details'),
              ElevatedButton(
                onPressed: () => _pickDate('next_vaccination_due'),
                child: Text(_formData['next_vaccination_due'].isEmpty
                    ? '다음 접종일 선택'
                    : '다음 접종일: ${_formData['next_vaccination_due']}'),
              ),
              _buildTextField('백신 비용 (₩)', 'cost',
                  keyboardType: TextInputType.number),
              _buildTextField('특이사항 및 메모', 'notes'),
              const SizedBox(height: 16),
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
