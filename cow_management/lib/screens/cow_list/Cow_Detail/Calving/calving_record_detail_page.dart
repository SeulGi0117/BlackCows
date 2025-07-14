import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/calving_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/calving_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Calving/calving_record_edit_page.dart';

class CalvingDetailPage extends StatefulWidget {
  final String recordId;

  const CalvingDetailPage({super.key, required this.recordId});

  @override
  State<CalvingDetailPage> createState() => _CalvingDetailPageState();
}

class _CalvingDetailPageState extends State<CalvingDetailPage> {
  CalvingRecord? _record;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    try {
      final token = context.read<UserProvider>().accessToken!;
      final provider = context.read<CalvingRecordProvider>();
      final result = await provider.fetchRecordById(widget.recordId, token);
      setState(() {
        _record = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '❌ 데이터를 불러오는 중 오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecord() async {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<CalvingRecordProvider>();
    final success = await provider.deleteRecord(widget.recordId, token);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제가 완료되었습니다')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했습니다')),
      );
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('해당 분만 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecord();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('$label:',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
          ),
          Expanded(
            child: Text(value != null && value.isNotEmpty ? value : '없음',
                style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String label, List<String>? values,
      {String suffix = ''}) {
    if (values == null || values.isEmpty) return const SizedBox();
    return _buildItem(label, values.map((v) => '$v$suffix').join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분만 상세 정보'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _record == null
              ? Center(child: Text(_error ?? '기록이 존재하지 않습니다.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('기본 정보',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _buildItem('기록일', _record!.recordDate),
                              _buildItem('시작 시간', _record!.calvingStartTime),
                              _buildItem('종료 시간', _record!.calvingEndTime),
                              _buildItem('난이도', _record!.calvingDifficulty),
                              _buildItem(
                                  '송아지 수', _record!.calfCount?.toString()),
                              _buildItem(
                                  '태반 배출 여부',
                                  _record!.placentaExpelled == true
                                      ? '예'
                                      : '아니오'),
                              _buildItem(
                                  '태반 배출 시간', _record!.placentaExpulsionTime),
                              _buildItem(
                                  '수의사 호출 여부',
                                  _record!.veterinarianCalled == true
                                      ? '예'
                                      : '아니오'),
                              _buildItem('비유 시작일', _record!.lactationStart),
                              _buildItem('모우 상태', _record!.damCondition),
                              _buildItem('비고', _record!.notes),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('송아지 정보',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _buildListItem('송아지 성별', _record!.calfGender),
                              _buildListItem(
                                  '송아지 체중',
                                  _record!.calfWeight
                                      ?.map((e) => '$e')
                                      .toList(),
                                  suffix: 'kg'),
                              _buildListItem('송아지 건강', _record!.calfHealth),
                              _buildListItem('합병증', _record!.complications),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CalvingEditPage(record: _record!),
                                  ),
                                );
                                if (updated == true && mounted) {
                                  await _fetchRecord();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('기록이 수정되었습니다')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('수정'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showDeleteConfirmDialog,
                              icon: const Icon(Icons.delete),
                              label: const Text('삭제'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }
}
