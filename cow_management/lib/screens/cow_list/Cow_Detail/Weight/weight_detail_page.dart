import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

class WeightDetailPage extends StatelessWidget {
  final WeightRecord record;

  const WeightDetailPage({super.key, required this.record});

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value ?? '정보 없음')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('체중 기록 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInfoRow('측정일', record.recordDate),
            _buildInfoRow('체중', record.weight?.toStringAsFixed(1)),
            _buildInfoRow('측정 시간', record.measurementTime),
            _buildInfoRow('측정 방법', record.measurementMethod),
            _buildInfoRow('체형점수', record.bodyConditionScore?.toString()),
            _buildInfoRow('기갑고', record.heightWithers?.toString()),
            _buildInfoRow('체장', record.bodyLength?.toString()),
            _buildInfoRow('흉위', record.chestGirth?.toString()),
            _buildInfoRow('증체율', record.growthRate?.toString()),
            _buildInfoRow('목표 체중', record.targetWeight?.toString()),
            _buildInfoRow('체중 등급', record.weightCategory),
            _buildInfoRow('측정자', record.measurer),
            _buildInfoRow('특이사항', record.notes),
          ],
        ),
      ),
    );
  }
}
