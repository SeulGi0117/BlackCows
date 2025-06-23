import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class TreatmentAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const TreatmentAddPage(
      {super.key, required this.cowId, required this.cowName});

  @override
  State<TreatmentAddPage> createState() => _TreatmentAddPageState();
}

class _TreatmentAddPageState extends State<TreatmentAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TreatmentRecord _record = TreatmentRecord.empty();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    if (token == null) return;

    _record.cowId = widget.cowId;

    final success =
        await Provider.of<TreatmentRecordProvider>(context, listen: false)
            .addRecord(_record, token);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('등록 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} 치료 기록 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: '치료 날짜 (YYYY-MM-DD)'),
                onSaved: (val) => _record.recordDate = val ?? '',
                validator: (val) => val!.isEmpty ? '치료 날짜를 입력하세요' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '치료 종류'),
                onSaved: (val) => _record.treatmentType = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '진단명'),
                onSaved: (val) => _record.diagnosis = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '치료 반응'),
                onSaved: (val) => _record.treatmentResponse = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '담당 수의사명'),
                onSaved: (val) => _record.veterinarian = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '비용 (원)'),
                keyboardType: TextInputType.number,
                onSaved: (val) =>
                    _record.treatmentCost = int.tryParse(val ?? ''),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('등록하기'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
