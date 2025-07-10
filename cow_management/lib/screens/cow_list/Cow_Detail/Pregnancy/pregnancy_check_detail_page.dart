import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/pregnancy_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Pregnancy/pregnancy_check_edit_page.dart';

class PregnancyCheckDetailPage extends StatefulWidget {
  final String recordId;

  const PregnancyCheckDetailPage({super.key, required this.recordId});

  @override
  State<PregnancyCheckDetailPage> createState() =>
      _PregnancyCheckDetailPageState();
}

class _PregnancyCheckDetailPageState extends State<PregnancyCheckDetailPage> {
  PregnancyCheckRecord? _record;
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
      final provider = context.read<PregnancyCheckProvider>();
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
    final provider = context.read<PregnancyCheckProvider>();
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
          content: const Text('이 임신감정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
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

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              value != null && value.isNotEmpty ? value : '없음',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        appBar:
            AppBar(title: const Text('임신감정 상세'), backgroundColor: Colors.green),
        body: Center(
          child: Text(_error ?? '데이터가 없습니다.'),
        ),
      );
    }

    final record = _record!;

    return Scaffold(
      appBar: AppBar(
        title: Text('임신감정 상세: ${record.recordDate}'),
        backgroundColor: Colors.green,
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
                  const Text('기본 정보',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow('감정일', record.recordDate),
                  _buildInfoRow('감정 방법', record.checkMethod),
                  _buildInfoRow('감정 결과', record.checkResult),
                  _buildInfoRow('임신 단계', '${record.pregnancyStage}일차'),
                  _buildInfoRow('태아 상태', record.fetusCondition),
                  _buildInfoRow('분만 예정일', record.expectedCalvingDate),
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
                  const Text('진료 정보',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow('수의사명', record.veterinarian),
                  _buildInfoRow(
                      '감정 비용', '${record.checkCost.toStringAsFixed(0)}원'),
                  _buildInfoRow('다음 감정일', record.nextCheckDate),
                ],
              ),
            ),
          ),
          if (record.additionalCare.isNotEmpty == true ||
              record.notes.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('기타 정보',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildInfoRow('추가 관리사항', record.additionalCare),
                    _buildInfoRow('비고', record.notes),
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
                        builder: (_) => PregnancyCheckEditPage(record: record),
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
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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
