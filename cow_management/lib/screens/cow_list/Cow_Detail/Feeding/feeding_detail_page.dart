import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:cow_management/providers/DetailPage/feeding_record_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Feeding/feeding_edit_page.dart';

class FeedDetailPage extends StatefulWidget {
  final String recordId;

  const FeedDetailPage({super.key, required this.recordId});

  @override
  State<FeedDetailPage> createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  FeedRecord? _record;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      final dio = Dio();

      final response = await dio.get(
        '${ApiConfig.baseUrl}/records/${widget.recordId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _record = FeedRecord.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '데이터를 불러오지 못했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사료급여 상세 정보'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '수정',
            onPressed: _record == null ? null : _editRecord,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
            onPressed: _record == null ? null : _confirmDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _record == null
                  ? const Center(child: Text('기록이 존재하지 않습니다.'))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          _buildItem('급여일', _record?.recordDate),
                          _buildItem('급여 시간', _record?.feedTime),
                          _buildItem('사료 종류', _record?.feedType),
                          _buildItem(
                            '급여량',
                            _record!.feedAmount > 0
                                ? '${_record!.feedAmount.toStringAsFixed(1)} kg'
                                : '미입력',
                          ),
                          _buildItem('사료 품질', _record?.feedQuality),
                          _buildItem('보충제 종류', _record?.supplementType),
                          _buildItem(
                            '보충제 급여량',
                            _record!.supplementAmount > 0
                                ? '${_record!.supplementAmount.toStringAsFixed(1)} kg'
                                : '미입력',
                          ),
                          _buildItem(
                            '음수량',
                            _record!.waterConsumption > 0
                                ? '${_record!.waterConsumption.toStringAsFixed(1)} L'
                                : '미입력',
                          ),
                          _buildItem('섭취 상태', _record?.appetiteCondition),
                          _buildItem(
                            '사료 효율',
                            _record!.feedEfficiency > 0
                                ? _record!.feedEfficiency.toStringAsFixed(2)
                                : '미입력',
                          ),
                          _buildItem(
                            '사료 단가',
                            _record!.costPerFeed > 0
                                ? '${_record!.costPerFeed.toStringAsFixed(0)} 원'
                                : '미입력',
                          ),
                          _buildItem('급여자', _record?.fedBy),
                          _buildItem('메모', _record?.notes),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              (value != null && value.isNotEmpty) ? value : '없음',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 사료급여 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('삭제'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      final provider = Provider.of<FeedRecordProvider>(context, listen: false);

      await provider.deleteRecord(widget.recordId, token!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제가 완료되었습니다.')),
        );
        Navigator.pop(context); // 삭제 후 뒤로 가기
      }
    }
  }

  void _editRecord() async {
    if (_record == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedEditPage(
          record: _record!,
        ),
      ),
    );

    // 수정 후 돌아왔을 때 새로고침
    if (result == true) {
      await _fetchRecord();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 수정되었습니다.')),
        );
      }
    }
  }
}
