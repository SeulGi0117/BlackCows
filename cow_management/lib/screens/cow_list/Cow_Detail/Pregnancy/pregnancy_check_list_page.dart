// pregnancy_check_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/pregnancy_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Pregnancy/pregnancy_check_detail_page.dart';

class PregnancyCheckListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const PregnancyCheckListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<PregnancyCheckListPage> createState() => _PregnancyCheckListPageState();
}

class _PregnancyCheckListPageState extends State<PregnancyCheckListPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      await Provider.of<PregnancyCheckProvider>(context, listen: false)
          .fetchRecords(widget.cowId, token!);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('임신감정 기록 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().contains('500')
            ? '서버 오류입니다. 잠시 후 다시 시도해주세요.'
            : '기록을 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<PregnancyCheckProvider>(context).records;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 임신감정 기록'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _buildBody(records),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/pregnancy_check/add',
            arguments: {
              'cowId': widget.cowId,
              'cowName': widget.cowName,
            },
          ).then((_) => _loadRecords());
        },
        backgroundColor: Colors.pink.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(List<PregnancyCheckRecord> records) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.pink),
            SizedBox(height: 16),
            Text('임신감정 기록을 불러오는 중...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pregnant_woman, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '임신감정 기록이 없습니다',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              '아래 + 버튼을 눌러 첫 번째 기록을 추가해보세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        return Card(
          child: ListTile(
            title: Text(record.checkResult.isNotEmpty
                ? record.checkResult
                : '감정 결과 없음'),
            subtitle: Text('감정일: ${record.recordDate}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PregnancyCheckDetailPage(
                      recordId: record.id!), // 목록에서 넘어온 id
                ),
              );
            },
          ),
        );
      },
    );
  }
}
