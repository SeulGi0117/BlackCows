import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/milking_record_provider.dart';
import 'package:cow_management/models/Detail/milking_record.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Milk/milk_edit_page.dart';

class MilkingRecordDetailPage extends StatefulWidget {
  final String recordId;

  const MilkingRecordDetailPage({super.key, required this.recordId});

  @override
  State<MilkingRecordDetailPage> createState() =>
      _MilkingRecordDetailPageState();
}

class _MilkingRecordDetailPageState extends State<MilkingRecordDetailPage> {
  MilkingRecord? _record;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    try {
      final token = context.read<UserProvider>().accessToken!;
      final provider = context.read<MilkingRecordProvider>();
      final fresh = await provider.fetchRecordById(widget.recordId, token);
      if (mounted) {
        setState(() {
          _record = fresh;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '❌ 데이터를 불러오는 중 오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🗑️ 기록 삭제'),
          content: const Text('이 착유 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final token = context.read<UserProvider>().accessToken!;
                final provider = context.read<MilkingRecordProvider>();
                final success =
                    await provider.deleteRecord(widget.recordId, token);
                if (success && mounted) {
                  Navigator.of(context).pop(); // 목록으로 돌아가기
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
        );
      },
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
            child: Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('착유 기록 상세'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    final record = _record!;

    return Scaffold(
      appBar: AppBar(
        title: Text('착유 상세: ${record.recordDate}'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard('📋 착유 정보', [
            _buildInfoRow('📅 날짜', record.recordDate),
            _buildInfoRow('🥛 생산량', '${record.milkYield}L'),
            _buildInfoRow('🔄 회차', '${record.milkingSession}회'),
            _buildInfoRow('⏱ 시작 시간', record.milkingStartTime),
            _buildInfoRow('⏱ 종료 시간', record.milkingEndTime),
          ]),
          _buildSectionCard('📊 품질 정보', [
            _buildInfoRow('🧈 유지방', '${record.fatPercentage}%'),
            _buildInfoRow('🍗 단백질', '${record.proteinPercentage}%'),
            _buildInfoRow('📈 전도도', '${record.conductivity}'),
            _buildInfoRow('🧬 체세포수', '${record.somaticCellCount}'),
            _buildInfoRow('🌡 온도', '${record.temperature}°C'),
            _buildInfoRow('🎨 색상', record.colorValue),
            _buildInfoRow('🩸 혈류 감지', record.bloodFlowDetected ? '예' : '아니오'),
            if (record.notes.isNotEmpty) _buildInfoRow('📝 비고', record.notes),
          ]),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MilkingRecordEditPage(
                          recordId: record.id,
                          recordData: record.toJson(),
                        ),
                      ),
                    );
                    if (updated == true && context.mounted) {
                      await _fetchRecord();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록이 수정되었습니다')),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDeleteConfirmDialog,
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
          ),
        ],
      ),
    );
  }
}
