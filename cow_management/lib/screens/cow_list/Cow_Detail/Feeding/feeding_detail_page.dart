import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/feeding_record_provider.dart';
import 'package:cow_management/models/feeding_record.dart';
import 'package:cow_management/providers/user_provider.dart';

class FeedingRecordDetailPage extends StatelessWidget {
  final FeedingRecord record;

  const FeedingRecordDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사료 기록 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('급여 날짜', record.feedingDate),
            _buildInfoRow('급여 시간', record.feedTime),
            _buildInfoRow('사료 종류', record.feedType),
            _buildInfoRow('급여량', '${record.amount} kg'),
            _buildInfoRow('비고', record.notes ?? '없음'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('정말 이 사료 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('삭제',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final token =
                        Provider.of<UserProvider>(context, listen: false)
                            .accessToken;

                    final success = await Provider.of<FeedingRecordProvider>(
                      context,
                      listen: false,
                    ).deleteRecord(record.id, token!);

                    if (success && context.mounted) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('삭제되었습니다')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('기록 삭제'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
