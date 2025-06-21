import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/feeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/models/feeding_record.dart';

class FeedingRecordListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const FeedingRecordListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<FeedingRecordListPage> createState() => _FeedingRecordListPageState();
}

class _FeedingRecordListPageState extends State<FeedingRecordListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    await Provider.of<FeedingRecordProvider>(context, listen: false)
        .fetchRecords(widget.cowId, token!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<FeedingRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} - 사료 기록')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('사료 기록이 없습니다.'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text('${record.feedType} - ${record.amount}kg'),
                      subtitle:
                          Text('${record.feedingDate} ${record.feedTime}'),
                      trailing: Text(record.notes ?? ''),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/feeding-record/detail',
                          arguments: record,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
