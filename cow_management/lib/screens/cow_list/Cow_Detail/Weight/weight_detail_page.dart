import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/weight_record_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Weight/weight_edit_page.dart';

class WeightDetailPage extends StatefulWidget {
  final String recordId;

  const WeightDetailPage({super.key, required this.recordId});

  @override
  State<WeightDetailPage> createState() => _WeightDetailPageState();
}

class _WeightDetailPageState extends State<WeightDetailPage> {
  WeightRecord? _record;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<WeightRecordProvider>();

    try {
      final result = await provider.fetchRecordById(widget.recordId, token);
      if (result != null) {
        setState(() {
          _record = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '데이터를 불러오지 못했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_record?.recordDate ?? '체중측정 상세'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildDetailBody(),
    );
  }

  Widget _buildDetailBody() {
    final record = _record!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard('⚖️ 기본 정보', [
          _buildInfoRow('📅 측정 날짜', record.recordDate),
          if (record.measurementTime != null)
            _buildInfoRow('⏰ 측정 시간', record.measurementTime!),
          if (record.measurer != null)
            _buildInfoRow('👨‍⚕️ 측정자', record.measurer!),
          if (record.measurementMethod != null)
            _buildInfoRow('🔧 측정 방법', record.measurementMethod!),
        ]),
        const SizedBox(height: 12),
        _buildSectionCard('📏 측정 정보', [
          if (record.weight != null)
            _buildInfoRow('⚖️ 체중', '${record.weight}kg'),
          if (record.heightWithers != null)
            _buildInfoRow('📐 체고', '${record.heightWithers}cm'),
          if (record.bodyLength != null)
            _buildInfoRow('📏 체장', '${record.bodyLength}cm'),
          if (record.chestGirth != null)
            _buildInfoRow('📊 흉위', '${record.chestGirth}cm'),
        ]),
        const SizedBox(height: 12),
        _buildSectionCard('🎯 체형 평가', [
          if (record.bodyConditionScore != null)
            _buildInfoRow('📊 체형점수(BCS)', record.bodyConditionScore.toString()),
          if (record.weightCategory != null)
            _buildInfoRow('📈 체중 분류', record.weightCategory!),
          if (record.growthRate != null)
            _buildInfoRow('📈 증체율', '${record.growthRate}%'),
          if (record.targetWeight != null)
            _buildInfoRow('🎯 목표 체중', '${record.targetWeight}kg'),
        ]),
        const SizedBox(height: 12),
        if (record.notes != null && record.notes!.isNotEmpty)
          _buildSectionCard('📝 추가 정보', [
            _buildInfoRow('📋 특이사항', record.notes!),
          ]),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeightEditPage(record: _record!),
                ),
              );
              if (result == true) _fetchRecord(); // 수정 반영
            },
            icon: const Icon(Icons.edit),
            label: const Text('수정'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmDialog(context),
            icon: const Icon(Icons.delete),
            label: const Text('삭제'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<WeightRecordProvider>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🗑️ 기록 삭제'),
        content: const Text('이 체중측정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success =
                  await provider.deleteRecord(widget.recordId, token);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제되었습니다')),
                );
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제에 실패했습니다')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
