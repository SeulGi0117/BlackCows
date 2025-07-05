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

  Future<void> _saveChanges() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final provider = Provider.of<FeedRecordProvider>(context, listen: false);

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

    await provider.updateRecord(widget.record.id!, updatedData, token!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록이 수정되었습니다.')),
      );
      Navigator.pop(context); // 이전 페이지로
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
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
        title: const Text('사료급여 기록 수정'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
            tooltip: '저장',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField('기록 날짜 (YYYY-MM-DD)', recordDateController),
            _buildTextField('급여 시간', feedTimeController),
            _buildTextField('사료 종류', feedTypeController),
            _buildTextField('급여량 (kg)', feedAmountController,
                inputType: TextInputType.number),
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
          ],
        ),
      ),
    );
  }
}
