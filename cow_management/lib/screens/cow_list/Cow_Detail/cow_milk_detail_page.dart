import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:logging/logging.dart';

class MilkingRecordListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const MilkingRecordListPage(
      {super.key, required this.cowId, required this.cowName});

  @override
  State<MilkingRecordListPage> createState() => _MilkingRecordListPageState();
}

class _MilkingRecordListPageState extends State<MilkingRecordListPage> {
  final _logger = Logger('CowMilkDetailPage');
  List<dynamic> milkingRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchMilkingRecords();
  }

  Future<void> _fetchMilkingRecords() async {
    final dio = Dio();
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (token == null || baseUrl == null) return;

    try {
      final response = await dio.get(
        '$baseUrl/detailed-records/cow/${widget.cowId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> allRecords = response.data;
        final milking =
            allRecords.where((r) => r['record_type'] == 'milking').toList();

        setState(() {
          milkingRecords = milking;
        });
      } else {
        throw Exception("조회 실패");
      }
    } catch (e) {
      _logger.severe("에러: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("데이터를 불러오지 못했습니다")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} 착유 기록')),
      body: milkingRecords.isEmpty
          ? const Center(child: Text("착유 기록이 없습니다"))
          : ListView.separated(
              itemCount: milkingRecords.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = milkingRecords[index];
                final date = record['record_date'] ?? '날짜 없음';
                final data = record['record_data'];
                final yield = data?['milk_yield'] ?? 0.0;

                return ListTile(
                  leading: const Icon(Icons.local_drink, color: Colors.blue),
                  title: Text('🥛 $date'),
                  subtitle: Text('생산량: ${yield}L'),
                );
              },
            ),
    );
  }
}
