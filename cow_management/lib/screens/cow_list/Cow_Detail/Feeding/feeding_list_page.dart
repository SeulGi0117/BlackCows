import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/providers/DetailPage/feeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Feeding/feeding_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Feeding/feeding_detail_page.dart';

class FeedListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const FeedListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<FeedListPage> createState() => _FeedListPageState();
}

class _FeedListPageState extends State<FeedListPage> {
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
      if (token == null || token.isEmpty) {
        throw Exception('토큰이 유효하지 않습니다.');
      }

      await Provider.of<FeedRecordProvider>(context, listen: false)
          .fetchRecords(widget.cowId, token);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('사료급여 기록 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '기록을 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<FeedRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 사료급여 기록'),
        backgroundColor: Colors.orange.shade400,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeedAddPage(
                cowId: widget.cowId,
                cowName: widget.cowName,
              ),
            ),
          ).then((_) => _loadRecords());
        },
        backgroundColor: Colors.orange.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(List<FeedRecord> records) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('사료급여 기록을 불러오는 중...'),
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
                backgroundColor: Colors.orange,
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
            Icon(Icons.rice_bowl, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '사료급여 기록이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('급여일: ${record.recordDate}'),
            subtitle: Text(
              '사료 종류: ${record.feedType.isNotEmpty ? record.feedType : '-'} | '
              '급여량: ${(record.feedAmount).toStringAsFixed(1)}kg',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              if (record.id != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedDetailPage(recordId: record.id!),
                  ),
                );

                if (result == true) {
                  _loadRecords(); // ✅ 삭제된 경우 목록 갱신
                }
              } else {
                print('⚠️ record.id가 null입니다');
              }
            },
          ),
        );
      },
    );
  }
}
