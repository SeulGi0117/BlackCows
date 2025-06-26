import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';

class EstrusDetailPage extends StatelessWidget {
  final EstrusRecord record;

  const EstrusDetailPage({super.key, required this.record});

  Widget _buildRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value ?? '정보 없음')),
        ],
      ),
    );
  }

  Widget _buildListRow(String title, List<String>? values) {
    final joined =
        (values == null || values.isEmpty) ? '정보 없음' : values.join(', ');
    return _buildRow(title, joined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('발정 기록 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildRow('기록 날짜', record.recordDate),
            _buildRow('발정 시작 시간', record.estrusStartTime),
            _buildRow('발정 강도', record.estrusIntensity),
            _buildRow('발정 지속시간', record.estrusDuration?.toString()),
            _buildListRow('발정 징후', record.behaviorSigns),
            _buildListRow('육안 관찰 사항', record.visualSigns),
            _buildRow('발견자', record.detectedBy),
            _buildRow('발견 방법', record.detectionMethod),
            _buildRow('다음 발정 예상일', record.nextExpectedEstrus),
            _buildRow(
                '교배 계획 여부', record.breedingPlanned == true ? '예정됨' : '없음'),
            _buildRow('메모', record.notes),
          ],
        ),
      ),
    );
  }
}
