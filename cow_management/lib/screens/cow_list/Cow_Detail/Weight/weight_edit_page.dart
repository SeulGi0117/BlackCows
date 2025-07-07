import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/weight_record_provider.dart';

class WeightEditPage extends StatefulWidget {
  final WeightRecord record;

  const WeightEditPage({super.key, required this.record});

  @override
  State<WeightEditPage> createState() => _WeightEditPageState();
}

class _WeightEditPageState extends State<WeightEditPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _formData = {
      'record_date': r.recordDate,
      'measurement_time': r.measurementTime ?? '',
      'measurer': r.measurer ?? '',
      'measurement_method': r.measurementMethod ?? '',
      'weight': r.weight?.toString() ?? '',
      'height_withers': r.heightWithers?.toString() ?? '',
      'body_length': r.bodyLength?.toString() ?? '',
      'chest_girth': r.chestGirth?.toString() ?? '',
      'body_condition_score': r.bodyConditionScore?.toString() ?? '',
      'weight_category': r.weightCategory ?? '',
      'growth_rate': r.growthRate?.toString() ?? '',
      'target_weight': r.targetWeight?.toString() ?? '',
      'notes': r.notes ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('체중측정 수정'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._buildTextFields(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('수정 완료', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    final List<Map<String, String>> fields = [
      {'label': '측정 날짜', 'key': 'record_date'},
      {'label': '측정 시간', 'key': 'measurement_time'},
      {'label': '측정자', 'key': 'measurer'},
      {'label': '측정 방법', 'key': 'measurement_method'},
      {'label': '체중(kg)', 'key': 'weight'},
      {'label': '체고(cm)', 'key': 'height_withers'},
      {'label': '체장(cm)', 'key': 'body_length'},
      {'label': '흉위(cm)', 'key': 'chest_girth'},
      {'label': 'BCS', 'key': 'body_condition_score'},
      {'label': '체중 분류', 'key': 'weight_category'},
      {'label': '증체율(%)', 'key': 'growth_rate'},
      {'label': '목표 체중(kg)', 'key': 'target_weight'},
      {'label': '특이사항', 'key': 'notes'},
    ];

    return fields.map((field) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: _formData[field['key']] ?? '',
          decoration: InputDecoration(
            labelText: field['label'],
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _formData[field['key']!] = value,
        ),
      );
    }).toList();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<WeightRecordProvider>();

    final updatedData = {
      'record_date': _formData['record_date'],
      'title': '체중측정',
      'description': '',
      'record_data': {
        'measurement_time': _formData['measurement_time'],
        'measurer': _formData['measurer'],
        'measurement_method': _formData['measurement_method'],
        'weight': double.tryParse(_formData['weight'] ?? ''),
        'height_withers': double.tryParse(_formData['height_withers'] ?? ''),
        'body_length': double.tryParse(_formData['body_length'] ?? ''),
        'chest_girth': double.tryParse(_formData['chest_girth'] ?? ''),
        'body_condition_score':
            double.tryParse(_formData['body_condition_score'] ?? ''),
        'weight_category': _formData['weight_category'],
        'growth_rate': double.tryParse(_formData['growth_rate'] ?? ''),
        'target_weight': double.tryParse(_formData['target_weight'] ?? ''),
        'notes': _formData['notes'],
      }
    };

    final success = await provider.updateRecord(
      widget.record.id!,
      updatedData,
      token,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정 완료되었습니다')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수정에 실패했습니다')),
      );
    }
  }
}
