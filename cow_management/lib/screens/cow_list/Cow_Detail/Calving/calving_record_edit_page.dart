import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/calving_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/calving_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class CalvingEditPage extends StatefulWidget {
  final CalvingRecord record;

  const CalvingEditPage({super.key, required this.record});

  @override
  State<CalvingEditPage> createState() => _CalvingEditPageState();
}

class _CalvingEditPageState extends State<CalvingEditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers['record_date'] =
        TextEditingController(text: widget.record.recordDate);
    _controllers['calving_start_time'] =
        TextEditingController(text: widget.record.calvingStartTime ?? '');
    _controllers['calving_end_time'] =
        TextEditingController(text: widget.record.calvingEndTime ?? '');
    _controllers['calving_difficulty'] =
        TextEditingController(text: widget.record.calvingDifficulty ?? '');
    _controllers['calf_count'] =
        TextEditingController(text: widget.record.calfCount?.toString() ?? '');
    _controllers['placenta_expulsion_time'] =
        TextEditingController(text: widget.record.placentaExpulsionTime ?? '');
    _controllers['lactation_start'] =
        TextEditingController(text: widget.record.lactationStart ?? '');
    _controllers['dam_condition'] =
        TextEditingController(text: widget.record.damCondition ?? '');
    _controllers['notes'] =
        TextEditingController(text: widget.record.notes ?? '');
    _controllers['calf_gender'] =
        TextEditingController(text: widget.record.calfGender?.join(', ') ?? '');
    _controllers['calf_weight'] = TextEditingController(
      text: widget.record.calfWeight?.map((e) => e.toString()).join(', ') ?? '',
    );
    _controllers['calf_health'] =
        TextEditingController(text: widget.record.calfHealth?.join(', ') ?? '');
    _controllers['complications'] = TextEditingController(
        text: widget.record.complications?.join(', ') ?? '');
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<CalvingRecordProvider>();

    final updated = CalvingRecord(
      id: widget.record.id,
      cowId: widget.record.cowId,
      recordDate: _controllers['record_date']!.text,
      calvingStartTime: _controllers['calving_start_time']!.text,
      calvingEndTime: _controllers['calving_end_time']!.text,
      calvingDifficulty: _controllers['calving_difficulty']!.text,
      calfCount: int.tryParse(_controllers['calf_count']!.text),
      placentaExpelled: widget.record.placentaExpelled,
      placentaExpulsionTime: _controllers['placenta_expulsion_time']!.text,
      veterinarianCalled: widget.record.veterinarianCalled,
      lactationStart: _controllers['lactation_start']!.text,
      damCondition: _controllers['dam_condition']!.text,
      notes: _controllers['notes']!.text,
      calfGender: _controllers['calf_gender']!
          .text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      calfWeight: _controllers['calf_weight']!
          .text
          .split(',')
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList(),
      calfHealth: _controllers['calf_health']!
          .text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      complications: _controllers['complications']!
          .text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    );

    final success = await provider.updateRecord(
      widget.record.id!,
      updated.toUpdateJson(),
      token,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정 실패'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField(String label, String key,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분만 기록 수정'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('기록일', 'record_date'),
              _buildTextField('시작 시간', 'calving_start_time'),
              _buildTextField('종료 시간', 'calving_end_time'),
              _buildTextField('난이도', 'calving_difficulty'),
              _buildTextField('송아지 수', 'calf_count',
                  keyboardType: TextInputType.number),
              _buildTextField('태반 배출 시간', 'placenta_expulsion_time'),
              _buildTextField('비유 시작일', 'lactation_start'),
              _buildTextField('모우 상태', 'dam_condition'),
              _buildTextField('비고', 'notes'),
              const SizedBox(height: 12),
              const Text('송아지 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField('송아지 성별 (쉼표로 구분)', 'calf_gender'),
              _buildTextField('송아지 체중 (쉼표로 구분)', 'calf_weight'),
              _buildTextField('송아지 건강 상태 (쉼표로 구분)', 'calf_health'),
              _buildTextField('합병증 (쉼표로 구분)', 'complications'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: Text(_isSubmitting ? '수정 중...' : '기록 수정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
