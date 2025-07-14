import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cow_management/models/Detail/Reproduction/calving_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/calving_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class CalvingAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const CalvingAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<CalvingAddPage> createState() => _CalvingAddPageState();
}

class _CalvingAddPageState extends State<CalvingAddPage> {
  final _formKey = GlobalKey<FormState>();
  final DateTime _selectedDate = DateTime.now();

  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _calfCountController = TextEditingController();
  final _calfGenderController = TextEditingController();
  final _calfWeightController = TextEditingController();
  final _calfHealthController = TextEditingController();
  final _placentaTimeController = TextEditingController();
  final _complicationsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _calvingDifficulty;
  bool? _placentaExpelled;
  bool _assistanceRequired = false;
  bool _veterinarianCalled = false;
  String? _damCondition;
  String? _lactationStart;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;

    final record = CalvingRecord(
      cowId: widget.cowId,
      recordDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      calvingStartTime: _startTimeController.text,
      calvingEndTime: _endTimeController.text,
      calvingDifficulty: _calvingDifficulty,
      calfCount: int.tryParse(_calfCountController.text),
      calfGender: _calfGenderController.text.split(','),
      calfWeight: _calfWeightController.text
          .split(',')
          .map((e) => double.tryParse(e) ?? 0)
          .toList(),
      calfHealth: _calfHealthController.text.split(','),
      placentaExpelled: _placentaExpelled,
      placentaExpulsionTime: _placentaTimeController.text,
      complications: _complicationsController.text.split(','),
      assistanceRequired: _assistanceRequired,
      veterinarianCalled: _veterinarianCalled,
      damCondition: _damCondition,
      lactationStart: _lactationStart,
      notes: _notesController.text,
    );

    final success =
        await Provider.of<CalvingRecordProvider>(context, listen: false)
            .addCalvingRecord(record, token);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분만 기록 등록 실패!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 분만 기록 추가'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 기본 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('기본 정보',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                          labelText: '분만 시작 시간 (HH:mm:ss)'),
                    ),
                    TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(labelText: '분만 완료 시간'),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: '분만 난이도'),
                      items: ['정상', '약간어려움', '어려움', '제왕절개']
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _calvingDifficulty = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 송아지 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('송아지 정보',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextFormField(
                      controller: _calfCountController,
                      decoration: const InputDecoration(labelText: '송아지 수'),
                    ),
                    TextFormField(
                      controller: _calfGenderController,
                      decoration: const InputDecoration(
                          labelText: '송아지 성별 리스트 (쉼표로 구분)'),
                    ),
                    TextFormField(
                      controller: _calfWeightController,
                      decoration: const InputDecoration(
                          labelText: '송아지 체중 리스트 (쉼표로 구분)'),
                    ),
                    TextFormField(
                      controller: _calfHealthController,
                      decoration:
                          const InputDecoration(labelText: '송아지 건강 상태 리스트'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 분만 상세 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('분만 상세',
                        style: Theme.of(context).textTheme.titleMedium),
                    DropdownButtonFormField<bool>(
                      decoration: const InputDecoration(labelText: '태반 배출 여부'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('예')),
                        DropdownMenuItem(value: false, child: Text('아니오')),
                      ],
                      onChanged: (val) =>
                          setState(() => _placentaExpelled = val),
                    ),
                    TextFormField(
                      controller: _placentaTimeController,
                      decoration: const InputDecoration(labelText: '태반 배출 시간'),
                    ),
                    TextFormField(
                      controller: _complicationsController,
                      decoration:
                          const InputDecoration(labelText: '합병증 리스트 (쉼표로 구분)'),
                    ),
                    SwitchListTile(
                      title: const Text('도움 필요 여부'),
                      value: _assistanceRequired,
                      onChanged: (val) =>
                          setState(() => _assistanceRequired = val),
                    ),
                    SwitchListTile(
                      title: const Text('수의사 호출 여부'),
                      value: _veterinarianCalled,
                      onChanged: (val) =>
                          setState(() => _veterinarianCalled = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 어미소 상태 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('어미소 상태',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '어미소 상태'),
                      onChanged: (val) => _damCondition = val,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: '비유 시작일 (yyyy-MM-dd)'),
                      onChanged: (val) => _lactationStart = val,
                    ),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: '비고 / 특이사항'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('분만 기록 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
