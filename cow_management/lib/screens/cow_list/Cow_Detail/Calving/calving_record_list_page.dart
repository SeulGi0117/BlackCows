import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/calving_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/calving_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Calving/calving_record_add_page.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Calving/calving_record_detail_page.dart';

class CalvingListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const CalvingListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<CalvingListPage> createState() => _CalvingListPageState();
}

class _CalvingListPageState extends State<CalvingListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    await Provider.of<CalvingRecordProvider>(context, listen: false)
        .fetchRecords(widget.cowId, token ?? '');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<CalvingRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 분만 기록'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('등록된 분만 기록이 없습니다.'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text(record.recordDate),
                      subtitle: Text(
                        '송아지 수: ${record.calfCount ?? '-'} | 난이도: ${record.calvingDifficulty ?? '-'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CalvingDetailPage(recordId: record.id!),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CalvingAddPage(
                cowId: widget.cowId,
                cowName: widget.cowName,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
