import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/providers/DetailPage/feeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:intl/intl.dart';

class FeedAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const FeedAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<FeedAddPage> createState() => _FeedAddPageState();
}

class _FeedAddPageState extends State<FeedAddPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final _recordDateController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _recordDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final provider = Provider.of<FeedRecordProvider>(context, listen: false);

    final record = FeedRecord(
      id: null,
      cowId: widget.cowId,
      recordDate: _recordDateController.text,
      feedTime: _formData['feed_time'],
      feedType: _formData['feed_type'],
      feedAmount: _formData['feed_amount'],
      feedQuality: _formData['feed_quality'],
      supplementType: _formData['supplement_type'],
      supplementAmount: _formData['supplement_amount'],
      waterConsumption: _formData['water_consumption'],
      appetiteCondition: _formData['appetite_condition'],
      feedEfficiency: _formData['feed_efficiency'],
      costPerFeed: _formData['cost_per_feed'],
      fedBy: _formData['fed_by'],
      notes: _formData['notes'],
    );

    final success = await provider.addRecord(record, token!);
    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('사료 기록 추가 실패'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(date);
        }
      },
    );
  }

  Widget _buildTextField(String label, String key, {bool isRequired = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: isRequired
          ? (val) {
              if (val == null || val.trim().isEmpty) {
                return '필수 항목입니다';
              }
              return null;
            }
          : null,
      onSaved: (val) => _formData[key] = val?.trim(),
    );
  }

  Widget _buildNumberField(String label, String key,
      {bool isRequired = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        if (isRequired && (val == null || val.trim().isEmpty)) {
          return '필수 항목입니다';
        }
        final parsed = double.tryParse(val!);
        if (parsed == null) return '숫자를 입력해주세요';
        return null;
      },
      onSaved: (val) => _formData[key] = double.tryParse(val ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 사료 기록 추가'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildDateField('기록일', _recordDateController),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildTextField('급여 시간', 'feed_time'),
                            const SizedBox(height: 10),
                            _buildTextField('사료 종류', 'feed_type',
                                isRequired: true),
                            const SizedBox(height: 10),
                            _buildNumberField('급여량(kg)', 'feed_amount',
                                isRequired: true),
                            const SizedBox(height: 10),
                            _buildTextField('사료 품질', 'feed_quality'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildTextField('첨가제 종류', 'supplement_type'),
                            const SizedBox(height: 10),
                            _buildNumberField('첨가제 양', 'supplement_amount'),
                            const SizedBox(height: 10),
                            _buildNumberField('음수량(L)', 'water_consumption'),
                            const SizedBox(height: 10),
                            _buildTextField('식욕 상태', 'appetite_condition'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildNumberField('사료 효율', 'feed_efficiency'),
                            const SizedBox(height: 10),
                            _buildNumberField('사료 비용', 'cost_per_feed'),
                            const SizedBox(height: 10),
                            _buildTextField('급여자', 'fed_by'),
                            const SizedBox(height: 10),
                            _buildTextField('비고', 'notes'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('사료 기록 저장'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
