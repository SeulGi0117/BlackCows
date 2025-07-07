import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/DetailPage/milking_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class MilkingRecordEditPage extends StatefulWidget {
  final String recordId;
  final Map<String, dynamic> recordData;

  const MilkingRecordEditPage(
      {super.key, required this.recordId, required this.recordData});

  @override
  State<MilkingRecordEditPage> createState() => _MilkingRecordEditPageState();
}

class _MilkingRecordEditPageState extends State<MilkingRecordEditPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.recordData);
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<MilkingRecordProvider>();
    final success =
        await provider.updateRecord(widget.recordId, _formData, token);

    setState(() => _isSubmitting = false);

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정이 완료되었습니다')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정에 실패했습니다')),
      );
    }
  }

  Widget _buildTextField(String key, String label, {bool isNumber = false}) {
    return TextFormField(
      initialValue: _formData[key]?.toString() ?? '',
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onSaved: (value) {
        _formData[key] = isNumber ? num.tryParse(value ?? '') : value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('착유 기록 수정'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField('milk_yield', '생산량', isNumber: true),
                    _buildTextField('milking_session', '착유 회차', isNumber: true),
                    _buildTextField('milking_start_time', '시작 시간'),
                    _buildTextField('milking_end_time', '종료 시간'),
                    _buildTextField('fat_percentage', '지방 (%)', isNumber: true),
                    _buildTextField('protein_percentage', '단백질 (%)',
                        isNumber: true),
                    _buildTextField('conductivity', '전도도', isNumber: true),
                    _buildTextField('somatic_cell_count', '체세포수',
                        isNumber: true),
                    _buildTextField('temperature', '온도 (℃)', isNumber: true),
                    _buildTextField('color_value', '색상'),
                    _buildTextField(
                        'blood_flow_detected', '혈류 감지 (true/false)'),
                    _buildTextField('notes', '비고'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      child: const Text('저장'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
