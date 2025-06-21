import 'package:flutter/material.dart';

class HealthCheckAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const HealthCheckAddPage(
      {super.key, required this.cowId, required this.cowName});

  @override
  State<HealthCheckAddPage> createState() => _HealthCheckAddPageState();
}

class _HealthCheckAddPageState extends State<HealthCheckAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _recordDateController = TextEditingController();
  final TextEditingController _checkTimeController = TextEditingController();
  final TextEditingController _bodyTempController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _respiratoryRateController =
      TextEditingController();
  final TextEditingController _bcsController = TextEditingController();
  final TextEditingController _udderController = TextEditingController();
  final TextEditingController _hoofController = TextEditingController();
  final TextEditingController _coatController = TextEditingController();
  final TextEditingController _eyeController = TextEditingController();
  final TextEditingController _noseController = TextEditingController();
  final TextEditingController _appetiteController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _examinerController = TextEditingController();
  final TextEditingController _nextCheckDateController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _abnormalSymptoms = [];

  final List<String> _symptomOptions = [
    "기침",
    "설사",
    "식욕부진",
    "운동장애",
    "체온 이상",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.cowName} 건강검진 추가"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_recordDateController, '기록 날짜 (YYYY-MM-DD)'),
              _buildTextField(_checkTimeController, '검진 시간 (HH:MM)'),
              _buildTextField(_bodyTempController, '체온 (°C)'),
              _buildTextField(_heartRateController, '심박수 (회/분)'),
              _buildTextField(_respiratoryRateController, '호흡수 (회/분)'),
              _buildTextField(_bcsController, '체형 점수 (1.0 ~ 5.0)'),
              _buildTextField(_udderController, '유방 상태'),
              _buildTextField(_hoofController, '발굽 상태'),
              _buildTextField(_coatController, '털 상태'),
              _buildTextField(_eyeController, '눈 상태'),
              _buildTextField(_noseController, '코 상태'),
              _buildTextField(_appetiteController, '식욕'),
              _buildTextField(_activityController, '활동 수준'),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('비정상 증상',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 10,
                children: _symptomOptions.map((symptom) {
                  return FilterChip(
                    label: Text(symptom),
                    selected: _abnormalSymptoms.contains(symptom),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _abnormalSymptoms.add(symptom)
                            : _abnormalSymptoms.remove(symptom);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildTextField(_examinerController, '검진자 이름'),
              _buildTextField(
                  _nextCheckDateController, '다음 검진 예정일 (YYYY-MM-DD)'),
              _buildTextField(_notesController, '비고/메모'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 전송 로직은 여기서 구현
                  }
                },
                child: const Text('기록 저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '값을 입력하세요';
          }
          return null;
        },
      ),
    );
  }
}
