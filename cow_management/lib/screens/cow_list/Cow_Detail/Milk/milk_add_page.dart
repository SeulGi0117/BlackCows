import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/providers/user_provider.dart';

class MilkingRecordPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const MilkingRecordPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<MilkingRecordPage> createState() => _MilkingRecordPageState();
}

class _MilkingRecordPageState extends State<MilkingRecordPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _bloodFlowDetected = false;

  // 컨트롤러 목록
  final _controllers = {
    'milk_yield': TextEditingController(),
    'milking_start_time': TextEditingController(),
    'milking_end_time': TextEditingController(),
    'milking_session': TextEditingController(),
    'conductivity': TextEditingController(),
    'somatic_cell_count': TextEditingController(),
    'color_value': TextEditingController(),
    'temperature': TextEditingController(),
    'fat_percentage': TextEditingController(),
    'protein_percentage': TextEditingController(),
    'air_flow_value': TextEditingController(),
    'lactation_number': TextEditingController(),
    'rumination_time': TextEditingController(),
    'collection_code': TextEditingController(),
    'collection_count': TextEditingController(),
    'notes': TextEditingController(),
  };

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'];

    if (token == null || apiUrl == null) return;

    final body = {
      "cow_id": widget.cowId,
      "record_date": DateFormat("yyyy-MM-dd").format(_selectedDate),
      "milk_yield": double.tryParse(_controllers['milk_yield']!.text) ?? 0,
      "milking_start_time": _controllers['milking_start_time']!.text,
      "milking_end_time": _controllers['milking_end_time']!.text,
      "milking_session":
          int.tryParse(_controllers['milking_session']!.text) ?? 0,
      "conductivity": double.tryParse(_controllers['conductivity']!.text) ?? 0,
      "somatic_cell_count":
          int.tryParse(_controllers['somatic_cell_count']!.text) ?? 0,
      "blood_flow_detected": _bloodFlowDetected,
      "color_value": _controllers['color_value']!.text,
      "temperature": double.tryParse(_controllers['temperature']!.text) ?? 0,
      "fat_percentage":
          double.tryParse(_controllers['fat_percentage']!.text) ?? 0,
      "protein_percentage":
          double.tryParse(_controllers['protein_percentage']!.text) ?? 0,
      "air_flow_value":
          double.tryParse(_controllers['air_flow_value']!.text) ?? 0,
      "lactation_number":
          int.tryParse(_controllers['lactation_number']!.text) ?? 0,
      "rumination_time":
          int.tryParse(_controllers['rumination_time']!.text) ?? 0,
      "collection_code": _controllers['collection_code']!.text,
      "collection_count":
          int.tryParse(_controllers['collection_count']!.text) ?? 0,
      "notes": _controllers['notes']!.text,
    };

    try {
      final response = await dio.post(
        "$apiUrl/records/milking",
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("착유 기록이 등록되었습니다.")),
        );
        Navigator.pushReplacementNamed(
          context,
          '/milking-records',
          arguments: {
            'cowId': widget.cowId,
            'cowName': widget.cowName,
          },
        );
      } else {
        throw Exception("등록 실패");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("착유 기록 등록")),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDatePicker(),
              _buildTextField('milking_start_time', '착유 시작 시간 (예: 06:00)'),
              _buildTextField('milking_end_time', '착유 종료 시간 (예: 06:20)'),
              _buildTextField('milk_yield', '우유 생산량 (L)', isNumber: true),
              _buildTextField('milking_session', '착유 회차', isNumber: true),
              _buildTextField('conductivity', '전도도', isNumber: true),
              _buildTextField('somatic_cell_count', '체세포 수', isNumber: true),
              _buildSwitch('혈류 감지 여부', (val) {
                setState(() => _bloodFlowDetected = val);
              }, _bloodFlowDetected),
              _buildTextField('color_value', '우유 색상'),
              _buildTextField('temperature', '온도 (℃)', isNumber: true),
              _buildTextField('fat_percentage', '유지방 (%)', isNumber: true),
              _buildTextField('protein_percentage', '단백질 (%)', isNumber: true),
              _buildTextField('air_flow_value', '공기 흐름 값', isNumber: true),
              _buildTextField('lactation_number', '산차', isNumber: true),
              _buildTextField('rumination_time', '반추 시간 (분)', isNumber: true),
              _buildTextField('collection_code', '수집 코드'),
              _buildTextField('collection_count', '수집 횟수', isNumber: true),
              _buildTextField('notes', '비고', maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRecord,
                child: const Text("기록 등록하기"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        const Text("날짜: "),
        Text(DateFormat("yyyy-MM-dd").format(_selectedDate)),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: const Text("변경"),
        ),
      ],
    );
  }

  Widget _buildTextField(String key, String label,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '필수 입력 항목입니다.';
          return null;
        },
      ),
    );
  }

  Widget _buildSwitch(String label, ValueChanged<bool> onChanged, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
