import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class EstrusAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const EstrusAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<EstrusAddPage> createState() => _EstrusAddPageState();
}

class _EstrusAddPageState extends State<EstrusAddPage> {
  final _formKey = GlobalKey<FormState>();
  EstrusRecord _record = EstrusRecord(cowId: '', recordDate: '');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    if (token == null) return;

    _record = _record.copyWith(cowId: widget.cowId);

    final success =
        await Provider.of<EstrusRecordProvider>(context, listen: false)
            .addEstrusRecord(_record, token);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} - 발정 기록 추가')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: '기록 날짜 (YYYY-MM-DD)'),
              onSaved: (val) =>
                  _record = _record.copyWith(recordDate: val ?? ''),
              validator: (val) =>
                  val == null || val.isEmpty ? '날짜는 필수입니다.' : null,
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: '발정 시작 시간 (HH:MM:SS)'),
              onSaved: (val) =>
                  _record = _record.copyWith(estrusStartTime: val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '발정 강도'),
              items: ['약', '중', '강'].map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (val) => setState(
                  () => _record = _record.copyWith(estrusIntensity: val)),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '발정 지속시간 (시간)'),
              keyboardType: TextInputType.number,
              onSaved: (val) => _record =
                  _record.copyWith(estrusDuration: int.tryParse(val ?? '')),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: '발정 징후 (쉼표로 구분: 승가허용, 불안, 울음 등)'),
              onSaved: (val) => _record = _record.copyWith(
                  behaviorSigns: val?.split(',').map((e) => e.trim()).toList()),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: '육안 관찰 사항 (쉼표로 구분: 점액분비, 외음부종 등)'),
              onSaved: (val) => _record = _record.copyWith(
                  visualSigns: val?.split(',').map((e) => e.trim()).toList()),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '발견자 이름'),
              onSaved: (val) => _record = _record.copyWith(detectedBy: val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '발견 방법'),
              items: ['육안관찰', '센서감지', '기타'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (val) => setState(
                  () => _record = _record.copyWith(detectionMethod: val)),
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: '다음 발정 예상일 (YYYY-MM-DD)'),
              onSaved: (val) =>
                  _record = _record.copyWith(nextExpectedEstrus: val),
            ),
            CheckboxListTile(
              title: const Text('교배 계획 있음'),
              value: _record.breedingPlanned ?? false,
              onChanged: (val) => setState(
                  () => _record = _record.copyWith(breedingPlanned: val)),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '메모'),
              maxLines: 3,
              onSaved: (val) => _record = _record.copyWith(notes: val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('등록하기'),
            )
          ],
        ),
      ),
    );
  }
}
