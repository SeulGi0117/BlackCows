import 'package:flutter/material.dart';
import 'package:cow_management/models/health_check_record.dart';
import 'package:cow_management/providers/health_check_provider.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class HealthCheckDetailPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const HealthCheckDetailPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<HealthCheckDetailPage> createState() => _HealthCheckDetailPageState();
}

class _HealthCheckDetailPageState extends State<HealthCheckDetailPage> {
  HealthCheckRecord? _record;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;

    if (token == null) {
      print('❌ 토큰 없음. 로그인 상태 확인 필요');
      return;
    }

    await Provider.of<HealthCheckProvider>(context, listen: false)
        .fetchAndSetRecords(widget.cowId, token);

    final recordList =
        await Provider.of<HealthCheckProvider>(context, listen: false)
            .fetchAndSetRecords(widget.cowId, token);

    setState(() {
      _record = recordList.isNotEmpty ? recordList.last : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_record == null) {
      return const Scaffold(body: Center(child: Text('기록이 없습니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('건강검진 상세 정보')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('체온: ${_record!.bodyTemperature}도'), // 예시
      ),
    );
  }
}
