import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Treatment/treatment_detail_page.dart';

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
      await Provider.of<TreatmentRecordProvider>(context, listen: false)
          .fetchRecords(widget.cowId, token!);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('치료 기록 목록 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().contains('500')
            ? '서버에 일시적인 문제가 있습니다.\n잠시 후 다시 시도해주세요.'
            : '치료 기록을 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<TreatmentRecordProvider>(context).records;
    print('치료 기록 목록: ${records.map((r) => r.toJson()).toList()}');

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 치료 기록'),
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
            '/treatment/add',
            arguments: {
              'cowId': widget.cowId,
              'cowName': widget.cowName,
            },
          ).then((_) => _loadRecords());
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(List<TreatmentRecord> records) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text('치료 기록을 불러오는 중...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
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
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '치료 기록이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '아래 + 버튼을 눌러 첫 번째 기록을 추가해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        final String notesText = record.notes?.isNotEmpty == true
            ? (record.notes!.length > 20
                ? '${record.notes!.substring(0, 20)}...'
                : record.notes!)
            : '메모 없음';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: const Icon(
                Icons.medical_services,
                color: Colors.red,
              ),
            ),
            title: Text(
              record.diagnosis ?? '진단명 없음',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('치료일: ${record.recordDate}'),
                if (record.medicationUsed != null &&
                    record.medicationUsed!.isNotEmpty)
                  Text('치료약물: ${record.medicationUsed!.join(", ")}'),
                Text(notesText), // ✅ 여기에 안전하게 넣어줌
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TreatmentDetailPage(recordId: record.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
