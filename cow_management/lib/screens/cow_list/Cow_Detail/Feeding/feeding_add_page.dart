import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/feeding_record.dart';
import 'package:cow_management/providers/feeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class FeedingRecordAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const FeedingRecordAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<FeedingRecordAddPage> createState() => _FeedingRecordAddPageState();
}

class _FeedingRecordAddPageState extends State<FeedingRecordAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _typeController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedingProvider =
        Provider.of<FeedingRecordProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 사료 기록 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_dateController, '날짜 (YYYY-MM-DD)',
                  validator: true),
              _buildTextField(_timeController, '시간 (HH:MM)', validator: true),
              _buildTextField(_typeController, '사료 종류', validator: true),
              _buildTextField(_amountController, '양 (kg)',
                  validator: true, isNumber: true),
              _buildTextField(_noteController, '비고', maxLines: 2),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final record = FeedingRecord(
                    id: '', // 생성 시 빈 값
                    cowId: widget.cowId,
                    feedingDate: _dateController.text,
                    feedTime: _timeController.text,
                    feedType: _typeController.text,
                    amount: double.tryParse(_amountController.text) ?? 0.0,
                    notes: _noteController.text,
                  );

                  final success = await feedingProvider.addRecord(
                      record, userProvider.accessToken!);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('기록 추가 실패')),
                    );
                  }
                },
                child: const Text('기록 추가하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool validator = false, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator
            ? (value) => value == null || value.isEmpty ? '필수 입력 항목입니다' : null
            : null,
      ),
    );
  }
}
