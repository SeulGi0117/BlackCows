import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/insemination_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Insemination/insemination_edit_page.dart';

class InseminationDetailPage extends StatefulWidget {
  final String recordId;
  final String cowId;
  final String cowName;

  const InseminationDetailPage({
    super.key,
    required this.recordId,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<InseminationDetailPage> createState() => _InseminationDetailPageState();
}

class _InseminationDetailPageState extends State<InseminationDetailPage> {
  InseminationRecord? _record;
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
      final provider = context.read<InseminationRecordProvider>();
      final result = await provider.fetchRecordById(widget.recordId, token);
      if (mounted) {
        setState(() {
          _record = result;
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

  Future<void> _deleteRecord() async {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<InseminationRecordProvider>();
    final success = await provider.deleteRecord(widget.recordId, token);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제가 완료되었습니다')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했습니다')),
      );
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗑️ 기록 삭제'),
          content: const Text('이 인공수정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _record == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('인공수정 기록 상세'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(_error ?? '데이터가 없습니다.',
              style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    final record = _record!;

    return Scaffold(
      appBar: AppBar(
        title: Text('인공수정 상세: ${record.recordDate}'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎯 기본 정보',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 수정 날짜', record.recordDate),
                  if (record.inseminationTime?.isNotEmpty == true)
                    _buildInfoRow('⏰ 수정 시간', record.inseminationTime!),
                  if (record.technicianName?.isNotEmpty == true)
                    _buildInfoRow('👨‍⚕️ 수의사', record.technicianName!),
                  if (record.inseminationMethod?.isNotEmpty == true)
                    _buildInfoRow('🔧 수정 방법', record.inseminationMethod!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🐂 종축 정보',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown)),
                  const SizedBox(height: 16),
                  if (record.bullBreed?.isNotEmpty == true)
                    _buildInfoRow('🐃 품종', record.bullBreed!),
                  if (record.semenQuality?.isNotEmpty == true)
                    _buildInfoRow('💧 정액 품질', record.semenQuality!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 결과 정보',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  const SizedBox(height: 16),
                  if (record.successProbability != null)
                    _buildInfoRow('📈 성공 확률',
                        '${record.successProbability!.toStringAsFixed(1)}%'),
                  if (record.pregnancyCheckScheduled?.isNotEmpty == true)
                    _buildInfoRow(
                        '📅 임신감정 예정일', record.pregnancyCheckScheduled!),
                  if (record.cost != null)
                    _buildInfoRow(
                        '💰 비용', '${record.cost!.toStringAsFixed(0)}원'),
                ],
              ),
            ),
          ),
          if (record.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 추가 정보',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple)),
                    const SizedBox(height: 16),
                    _buildInfoRow('📋 특이사항', record.notes!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InseminationEditPage(record: record),
                      ),
                    );
                    if (updated == true && mounted) {
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
