import 'package:cow_management/screens/cow_list/Cow_Detail/Health/health_check_edit_page.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';

class HealthCheckDetailPage extends StatefulWidget {
  final String recordId;

  const HealthCheckDetailPage({super.key, required this.recordId});

  @override
  State<HealthCheckDetailPage> createState() => _HealthCheckDetailPageState();
}

class _HealthCheckDetailPageState extends State<HealthCheckDetailPage> {
  HealthCheckRecord? _record;
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
      final provider = context.read<HealthCheckProvider>();
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

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🗑️ 기록 삭제'),
          content: const Text('이 건강검진 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final token = context.read<UserProvider>().accessToken!;
                final provider = context.read<HealthCheckProvider>();
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
          title: const Text('건강검진 상세'),
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
        title: Text('건강검진 상세: ${record.recordDate}'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard('🏥 기본 정보', [
            _buildInfoRow('📅 검진 날짜', record.recordDate),
            _buildInfoRow('⏰ 검진 시간', record.checkTime),
            _buildInfoRow('👨‍⚕️ 검진자', record.examiner),
          ]),
          _buildSectionCard('🌡️ 생체 신호', [
            _buildInfoRow('🌡️ 체온', '${record.bodyTemperature}°C'),
            _buildInfoRow('❤️ 심박수', '${record.heartRate}회/분'),
            _buildInfoRow('💨 호흡수', '${record.respiratoryRate}회/분'),
            _buildInfoRow('📊 체형점수(BCS)', record.bodyConditionScore.toString()),
          ]),
          _buildSectionCard('🔍 신체 검사', [
            if (record.udderCondition.isNotEmpty)
              _buildInfoRow('🍼 유방 상태', record.udderCondition),
            if (record.eyeCondition.isNotEmpty)
              _buildInfoRow('👁️ 눈 상태', record.eyeCondition),
            if (record.noseCondition.isNotEmpty)
              _buildInfoRow('👃 코 상태', record.noseCondition),
            if (record.coatCondition.isNotEmpty)
              _buildInfoRow('🦌 털 상태', record.coatCondition),
            if (record.hoofCondition.isNotEmpty)
              _buildInfoRow('🦶 발굽 상태', record.hoofCondition),
          ]),
          if (record.activityLevel.isNotEmpty || record.appetite.isNotEmpty)
            _buildSectionCard('🎭 행동 평가', [
              if (record.activityLevel.isNotEmpty)
                _buildInfoRow('🏃 활동 수준', record.activityLevel),
              if (record.appetite.isNotEmpty)
                _buildInfoRow('🍽️ 식욕 수준', record.appetite),
            ]),
          if (record.abnormalSymptoms.isNotEmpty)
            _buildSectionCard('⚠️ 이상 증상', [
              _buildInfoRow('🚨 증상', record.abnormalSymptoms.join(', ')),
            ]),
          _buildSectionCard('📝 추가 정보', [
            if (record.nextCheckDate.isNotEmpty)
              _buildInfoRow('📅 다음 검진 예정일', record.nextCheckDate),
            if (record.notes.isNotEmpty) _buildInfoRow('📋 특이사항', record.notes),
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
                        builder: (_) => HealthEditPage(record: _record!),
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
          ),
        ],
      ),
    );
  }
}
