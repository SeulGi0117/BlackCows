import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';

class HealthCheckDetailPage extends StatelessWidget {
  final HealthCheckRecord record;

  const HealthCheckDetailPage({
    super.key,
    required this.record,
  });

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('건강검진 상세 보기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailItem('검진 날짜', record.recordDate),
            _buildDetailItem('검진 시간', record.checkTime),
            _buildDetailItem('체온', '${record.bodyTemperature} ℃'),
            _buildDetailItem('심박수', '${record.heartRate}'),
            _buildDetailItem('호흡수', '${record.respiratoryRate}'),
            _buildDetailItem('체형 점수', '${record.bodyConditionScore}'),
            _buildDetailItem('유방 상태', record.udderCondition),
            _buildDetailItem('발굽 상태', record.hoofCondition),
            _buildDetailItem('털 상태', record.coatCondition),
            _buildDetailItem('눈 상태', record.eyeCondition),
            _buildDetailItem('코 상태', record.noseCondition),
            _buildDetailItem('식욕', record.appetite),
            _buildDetailItem('활동 수준', record.activityLevel),
            _buildDetailItem('이상 증상', record.abnormalSymptoms.join(', ')),
            _buildDetailItem('검진자', record.examiner),
            _buildDetailItem('다음 검진 예정일', record.nextCheckDate),
            _buildDetailItem('특이사항', record.notes),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/health-check/edit',
                  arguments: {'record': record},
                );
              },
              child: const Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }
}
