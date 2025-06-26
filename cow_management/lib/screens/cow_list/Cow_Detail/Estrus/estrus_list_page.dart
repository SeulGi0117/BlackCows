import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Estrus/estrus_detail.dart';

class EstrusRecordListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const EstrusRecordListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<EstrusRecordListPage> createState() => _EstrusRecordListPageState();
}

class _EstrusRecordListPageState extends State<EstrusRecordListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final provider = Provider.of<EstrusRecordProvider>(context, listen: false);
    final records = await provider.fetchRecords(widget.cowId, token!);

    print("📦 불러온 발정 기록 수: ${records.length}");

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<EstrusRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(title: Text("${widget.cowName}의 발정 기록")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("발정 기록이 없습니다."))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title:
                          Text("발정 강도: ${record.estrusIntensity ?? '정보 없음'}"),
                      subtitle: Text("발정일: ${record.recordDate}"),
                    );
                  },
                ),
    );
  }
}
