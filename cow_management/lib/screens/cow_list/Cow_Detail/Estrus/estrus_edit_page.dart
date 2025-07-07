import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class EstrusEditPage extends StatefulWidget {
  final String recordId;

  const EstrusEditPage({super.key, required this.recordId});

  @override
  State<EstrusEditPage> createState() => _EstrusEditPageState();
}

class _EstrusEditPageState extends State<EstrusEditPage> {
  final _formKey = GlobalKey<FormState>();
  late EstrusRecord _record;

  // 컨트롤러
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _detectedByController = TextEditingController();
  final TextEditingController _detectionMethodController =
      TextEditingController();
  final TextEditingController _estrusIntensityController =
      TextEditingController();
  final TextEditingController _estrusDurationController =
      TextEditingController();
  final TextEditingController _behaviorSignsController =
      TextEditingController();
  final TextEditingController _visualSignsController = TextEditingController();
  final TextEditingController _nextExpectedEstrusController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _breedingPlanned = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<EstrusRecordProvider>();
    final fetched = await provider.fetchRecordById(widget.recordId, token);
    if (fetched != null) {
      setState(() {
        _record = fetched;
        _dateController.text = _record.recordDate;
        _timeController.text = _record.estrusStartTime ?? '';
        _detectedByController.text = _record.detectedBy ?? '';
        _detectionMethodController.text = _record.detectionMethod ?? '';
        _estrusIntensityController.text = _record.estrusIntensity ?? '';
        _estrusDurationController.text =
            _record.estrusDuration?.toString() ?? '';
        _behaviorSignsController.text = _record.behaviorSigns?.join(', ') ?? '';
        _visualSignsController.text = _record.visualSigns?.join(', ') ?? '';
        _nextExpectedEstrusController.text = _record.nextExpectedEstrus ?? '';
        _notesController.text = _record.notes ?? '';
        _breedingPlanned = _record.breedingPlanned ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedRecord = _record.copyWith(
        recordDate: _dateController.text,
        estrusStartTime: _timeController.text,
        detectedBy: _detectedByController.text,
        detectionMethod: _detectionMethodController.text,
        estrusIntensity: _estrusIntensityController.text,
        estrusDuration: int.tryParse(_estrusDurationController.text),
        behaviorSigns: _behaviorSignsController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        visualSigns: _visualSignsController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        nextExpectedEstrus: _nextExpectedEstrusController.text,
        breedingPlanned: _breedingPlanned,
        notes: _notesController.text,
      );

      final token = context.read<UserProvider>().accessToken!;
      await context
          .read<EstrusRecordProvider>()
          .updateRecord(_record.id!, updatedRecord.toJson(), token);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('발정 기록 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('발정 날짜', _dateController),
              _buildTextField('발정 시간', _timeController),
              _buildTextField('발견자', _detectedByController),
              _buildTextField('발견 방법', _detectionMethodController),
              _buildTextField('발정 강도', _estrusIntensityController),
              _buildTextField('지속 시간 (시간)', _estrusDurationController),
              _buildTextField('행동 징후 (쉼표 구분)', _behaviorSignsController),
              _buildTextField('육안 관찰 (쉼표 구분)', _visualSignsController),
              _buildTextField('다음 발정 예상일', _nextExpectedEstrusController),
              _buildTextField('특이사항', _notesController),
              SwitchListTile(
                title: const Text('교배 계획'),
                value: _breedingPlanned,
                onChanged: (val) => setState(() => _breedingPlanned = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('수정 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}
