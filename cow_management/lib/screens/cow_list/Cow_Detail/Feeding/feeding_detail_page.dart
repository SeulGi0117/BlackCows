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

  Widget _buildCard(String title, String? content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content != null && content.isNotEmpty ? content : '없음'),
      ),
    );
  }

  Widget _buildCardNumber(String title, num? value, {String? unit}) {
    return _buildCard(
      title,
      (value != null && value > 0) ? '${value.toString()}${unit ?? ''}' : '미입력',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사료급여 상세 정보'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        actions: [
          if (_record != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editRecord,
            ),
          if (_record != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _record == null
                  ? const Center(child: Text('기록이 존재하지 않습니다.'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildCard('급여일', _record?.recordDate),
                        _buildCard('급여 시간', _record?.feedTime),
                        _buildCard('사료 종류', _record?.feedType),
                        _buildCardNumber('급여량', _record?.feedAmount,
                            unit: ' kg'),
                        _buildCard('사료 품질', _record?.feedQuality),
                        _buildCard('보충제 종류', _record?.supplementType),
                        _buildCardNumber('보충제 급여량', _record?.supplementAmount,
                            unit: ' kg'),
                        _buildCardNumber('음수량', _record?.waterConsumption,
                            unit: ' L'),
                        _buildCard('섭취 상태', _record?.appetiteCondition),
                        _buildCardNumber('사료 효율', _record?.feedEfficiency),
                        _buildCardNumber('사료 단가', _record?.costPerFeed,
                            unit: ' 원'),
                        _buildCard('급여자', _record?.fedBy),
                        _buildCard('메모', _record?.notes),
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
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
        Navigator.pop(context, true);
      }
    }
  }

  void _editRecord() async {
    if (_record == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedEditPage(record: _record!)),
    );
    if (result == true) await _fetchRecord();
  }
}
