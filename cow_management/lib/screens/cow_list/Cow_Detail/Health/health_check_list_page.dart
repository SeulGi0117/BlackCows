import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Health/health_check_detail_page.dart';

class HealthCheckListPage extends StatelessWidget {
  final String cowId;
  final String cowName;

  const HealthCheckListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });
  Future<void> _fetchFilteredRecords(BuildContext context) async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    await Provider.of<HealthCheckProvider>(context, listen: false)
        .fetchFilteredRecords(cowId, token!, 'health_check');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$cowName - 건강검진 목록')),
      body: FutureBuilder<void>(
        future: Provider.of<HealthCheckProvider>(context, listen: false).fetchRecords(cowId, Provider.of<UserProvider>(context, listen: false).accessToken!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = Provider.of<HealthCheckProvider>(context).records;

          if (records.isEmpty) {
            return const Center(child: Text('기록이 없습니다.'));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(record.recordDate),
                subtitle: Text('체온: \\${record.bodyTemperature != null ? record.bodyTemperature.toString() + '℃' : '-'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HealthCheckDetailPage(record: record),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
