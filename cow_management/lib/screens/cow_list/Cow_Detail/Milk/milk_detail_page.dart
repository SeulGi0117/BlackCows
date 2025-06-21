import 'package:flutter/material.dart';

class MilkingRecordDetailPage extends StatelessWidget {
  const MilkingRecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> record =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final data = record['record_data'] ?? {};
    final recordDate = record['record_date'] ?? '알 수 없음';

    return Scaffold(
      appBar: AppBar(title: Text('착유 상세: $recordDate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('🗓 날짜: $recordDate'),
          Text('🥛 생산량: ${data['milk_yield']} L'),
          Text(
              '🕐 시간: ${data['milking_start_time']} ~ ${data['milking_end_time']}'),
          Text('📊 전도도: ${data['conductivity']}'),
          Text('🧬 체세포수: ${data['somatic_cell_count']}'),
          Text('💧 색상: ${data['color_value']}'),
          Text('🔥 온도: ${data['temperature']} °C'),
          Text('🧈 유지율: ${data['fat_percentage']} %'),
          Text('🍗 단백질: ${data['protein_percentage']} %'),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: 수정 페이지로 이동
                },
                child: const Text('수정'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  // TODO: 삭제 확인 후 삭제 로직
                },
                child: const Text('삭제'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
