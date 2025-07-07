import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/feeding_record_provider.dart';

class FeedEditPage extends StatefulWidget {
  final FeedRecord record;

  const FeedEditPage({super.key, required this.record});

  @override
  State<FeedEditPage> createState() => _FeedEditPageState();
}

class _FeedEditPageState extends State<FeedEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController recordDateController;
  late TextEditingController feedTimeController;
  late TextEditingController feedTypeController;
  late TextEditingController feedAmountController;
  late TextEditingController feedQualityController;
  late TextEditingController supplementTypeController;
  late TextEditingController supplementAmountController;
  late TextEditingController waterConsumptionController;
  late TextEditingController appetiteConditionController;
  late TextEditingController feedEfficiencyController;
  late TextEditingController costPerFeedController;
  late TextEditingController fedByController;
  late TextEditingController notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    recordDateController = TextEditingController(text: r.recordDate);
    feedTimeController = TextEditingController(text: r.feedTime);
    feedTypeController = TextEditingController(text: r.feedType);
    feedAmountController = TextEditingController(text: r.feedAmount.toString());
    feedQualityController = TextEditingController(text: r.feedQuality);
    supplementTypeController = TextEditingController(text: r.supplementType);
    supplementAmountController =
        TextEditingController(text: r.supplementAmount.toString());
    waterConsumptionController =
        TextEditingController(text: r.waterConsumption.toString());
    appetiteConditionController =
        TextEditingController(text: r.appetiteCondition);
    feedEfficiencyController =
        TextEditingController(text: r.feedEfficiency.toString());
    costPerFeedController =
        TextEditingController(text: r.costPerFeed.toString());
    fedByController = TextEditingController(text: r.fedBy);
    notesController = TextEditingController(text: r.notes);
  }

  @override
  void dispose() {
    recordDateController.dispose();
    feedTimeController.dispose();
    feedTypeController.dispose();
    feedAmountController.dispose();
    feedQualityController.dispose();
    supplementTypeController.dispose();
    supplementAmountController.dispose();
    waterConsumptionController.dispose();
    appetiteConditionController.dispose();
    feedEfficiencyController.dispose();
    costPerFeedController.dispose();
    fedByController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final updatedData = {
      'record_date': recordDateController.text,
      'record_data': {
        'feed_time': feedTimeController.text,
        'feed_type': feedTypeController.text,
        'feed_amount': double.tryParse(feedAmountController.text) ?? 0.0,
        'feed_quality': feedQualityController.text,
        'supplement_type': supplementTypeController.text,
        'supplement_amount':
            double.tryParse(supplementAmountController.text) ?? 0.0,
        'water_consumption':
            double.tryParse(waterConsumptionController.text) ?? 0.0,
        'appetite_condition': appetiteConditionController.text,
        'feed_efficiency':
            double.tryParse(feedEfficiencyController.text) ?? 0.0,
        'cost_per_feed': double.tryParse(costPerFeedController.text) ?? 0.0,
        'fed_by': fedByController.text,
        'notes': notesController.text,
      }
    };

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final provider = Provider.of<FeedRecordProvider>(context, listen: false);
    await provider.updateRecord(widget.record.id!, updatedData, token!);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록이 수정되었습니다.')),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사료급여 기록 수정'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('기록 날짜 (YYYY-MM-DD)', recordDateController,
                  validator: (v) =>
                      v == null || v.isEmpty ? '날짜를 입력해주세요' : null),
              _buildTextField('급여 시간', feedTimeController),
              _buildTextField('사료 종류', feedTypeController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '사료 종류는 필수입니다' : null),
              _buildTextField('급여량 (kg)', feedAmountController,
                  inputType: TextInputType.number, validator: (v) {
                if (v == null || v.trim().isEmpty) return '급여량은 필수입니다';
                final parsed = double.tryParse(v);
                if (parsed == null) return '숫자를 입력해주세요';
                return null;
              }),
              _buildTextField('사료 품질', feedQualityController),
              _buildTextField('보충제 종류', supplementTypeController),
              _buildTextField('보충제 급여량 (kg)', supplementAmountController,
                  inputType: TextInputType.number),
              _buildTextField('음수량 (L)', waterConsumptionController,
                  inputType: TextInputType.number),
              _buildTextField('섭취 상태', appetiteConditionController),
              _buildTextField('사료 효율', feedEfficiencyController,
                  inputType: TextInputType.number),
              _buildTextField('사료 단가 (원)', costPerFeedController,
                  inputType: TextInputType.number),
              _buildTextField('급여자', fedByController),
              _buildTextField('메모', notesController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
