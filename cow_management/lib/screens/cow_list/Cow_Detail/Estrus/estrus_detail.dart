import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Estrus/estrus_edit_page.dart';

class EstrusDetailPage extends StatefulWidget {
  final String recordId;

  const EstrusDetailPage({super.key, required this.recordId});

  @override
  State<EstrusDetailPage> createState() => _EstrusDetailPageState();
}

class _EstrusDetailPageState extends State<EstrusDetailPage> {
  EstrusRecord? _record;
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
      final provider = context.read<EstrusRecordProvider>();
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
    final provider = context.read<EstrusRecordProvider>();
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
          content: const Text('이 발정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
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
          title: const Text('발정 기록 상세'),
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
        title: Text('발정 기록 상세: ${record.recordDate}'),
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
                  const Text('💕 기본 정보',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink)),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 발정 날짜', record.recordDate),
                  if (record.estrusStartTime != null &&
                      record.estrusStartTime!.isNotEmpty)
                    _buildInfoRow('⏰ 발정 시간', record.estrusStartTime!),
                  if (record.detectedBy != null &&
                      record.detectedBy!.isNotEmpty)
                    _buildInfoRow('👨‍🌾 발견자', record.detectedBy!),
                  if (record.detectionMethod != null &&
                      record.detectionMethod!.isNotEmpty)
                    _buildInfoRow('🔍 발견 방법', record.detectionMethod!),
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
                  const Text('🌡️ 발정 특성',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  const SizedBox(height: 16),
                  if (record.estrusIntensity != null &&
                      record.estrusIntensity!.isNotEmpty)
                    _buildInfoRow('🔥 발정 강도', record.estrusIntensity!),
                  if (record.estrusDuration != null &&
                      record.estrusDuration! > 0)
                    _buildInfoRow('⏱️ 지속 시간', '${record.estrusDuration}시간'),
                  if (record.behaviorSigns != null &&
                      record.behaviorSigns!.isNotEmpty)
                    _buildInfoRow('🎭 행동 징후', record.behaviorSigns!.join(', ')),
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
                  const Text('🔬 생리적 징후',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  const SizedBox(height: 16),
                  if (record.visualSigns != null &&
                      record.visualSigns!.isNotEmpty)
                    _buildInfoRow('👁️ 육안 관찰', record.visualSigns!.join(', ')),
                  if (record.nextExpectedEstrus != null &&
                      record.nextExpectedEstrus!.isNotEmpty)
                    _buildInfoRow('📅 다음 발정 예상일', record.nextExpectedEstrus!),
                  if (record.breedingPlanned != null)
                    _buildInfoRow(
                        '🎯 교배 계획', record.breedingPlanned! ? '예정됨' : '없음'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (record.notes != null && record.notes!.isNotEmpty)
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EstrusEditPage(recordId: record.id!),
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
