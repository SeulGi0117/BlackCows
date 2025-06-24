import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class TreatmentListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const TreatmentListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<TreatmentListPage> createState() => _TreatmentListPageState();
}

class _TreatmentListPageState extends State<TreatmentListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    await Provider.of<TreatmentRecordProvider>(context, listen: false)
        .fetchRecords(widget.cowId, token!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<TreatmentRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} 치료 기록')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('기록이 없습니다.'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text(record.diagnosis ?? '진단명 없음'),
                      subtitle: Text('치료일: ${record.recordDate}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/treatment/detail',
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
