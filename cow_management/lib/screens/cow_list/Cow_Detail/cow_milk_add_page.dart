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

  final TextEditingController _milkYieldController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _fatPercentageController =
      TextEditingController();
  final TextEditingController _proteinPercentageController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final bool _bloodFlowDetected = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _milkYieldController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _temperatureController.dispose();
    _fatPercentageController.dispose();
    _proteinPercentageController.dispose();
    _notesController.dispose();
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
      "type": "milking",
      "record_date": DateFormat("yyyy-MM-dd").format(_selectedDate),
      "milking_start_time": _startTimeController.text,
      "milking_end_time": _endTimeController.text,
      "milk_yield": double.tryParse(_milkYieldController.text) ?? 0,
      "temperature": double.tryParse(_temperatureController.text) ?? 0,
      "fat_percentage": double.tryParse(_fatPercentageController.text) ?? 0,
      "protein_percentage":
          double.tryParse(_proteinPercentageController.text) ?? 0,
      "blood_flow_detected": _bloodFlowDetected,
      "notes": _notesController.text,
    };

    try {
      final response = await dio.post(
        "$apiUrl/detailed-records/milking",
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('📦 생성 응답: ${response.data}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("착유 기록이 등록되었습니다.")),
        );
        print("✅ 생성 성공, 서버에서 받은 데이터: ${response.data}");
        // ✅ 등록 완료 후 기록 리스트 페이지로 이동
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDatePicker(),
              _buildTextField(_startTimeController, "착유 시작 시간 (예: 06:00)"),
              _buildTextField(_endTimeController, "착유 종료 시간 (예: 06:20)"),
              _buildTextField(_milkYieldController, "우유 생산량 (L)",
                  isNumber: true),
              _buildTextField(_temperatureController, "온도 (℃)", isNumber: true),
              _buildTextField(_fatPercentageController, "유지방 (%)",
                  isNumber: true),
              _buildTextField(_proteinPercentageController, "단백질 (%)",
                  isNumber: true),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
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
}
