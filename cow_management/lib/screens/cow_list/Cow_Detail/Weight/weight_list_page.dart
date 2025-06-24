import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';
import 'package:cow_management/providers/DetailPage/Health/weight_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class WeightListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const WeightListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<WeightListPage> createState() => _WeightListPageState();
}

class _WeightListPageState extends State<WeightListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    await Provider.of<WeightRecordProvider>(context, listen: false)
        .fetchRecords(widget.cowId, token!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<WeightRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} 체중 기록')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('기록이 없습니다.'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text(
                          '${record.weight?.toStringAsFixed(1) ?? "미입력"} kg'),
                      subtitle: Text('측정일: ${record.recordDate}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/weight/detail',
                          arguments: {
                            'cowId': widget.cowId,
                            'cowName': widget.cowName,
                            'record': record,
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
