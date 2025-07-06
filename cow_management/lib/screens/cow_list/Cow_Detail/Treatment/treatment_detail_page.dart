import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Treatment/treatment_edit_page.dart';

class TreatmentDetailPage extends StatefulWidget {
  final String recordId;

  const TreatmentDetailPage({super.key, required this.recordId});

  @override
  State<TreatmentDetailPage> createState() => _TreatmentDetailPageState();
}

class _TreatmentDetailPageState extends State<TreatmentDetailPage> {
  late TreatmentRecord _record;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<TreatmentRecordProvider>();
    final fetched = await provider.fetchRecordById(widget.recordId, token);

    if (fetched != null) {
      setState(() {
        _record = fetched;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록을 불러오지 못했습니다.')),
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('치료 기록 삭제'),
        content: const Text('이 치료 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기
              final token = context.read<UserProvider>().accessToken!;
              final provider = context.read<TreatmentRecordProvider>();
              final success =
                  await provider.deleteRecord(widget.recordId, token);

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제가 완료되었습니다.')),
                  );
                  Navigator.pop(context, true); // 돌아가서 목록 새로고침 유도
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제에 실패했습니다.')),
                  );
                }
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('치료 기록 상세'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '수정',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TreatmentEditPage(record: _record),
                ),
              );
              if (updated == true) _fetchRecord();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('🩺 기본 정보', [
                    _buildInfoRow('치료일', _record.recordDate),
                    if (_record.treatmentTime != null)
                      _buildInfoRow('치료 시간', _record.treatmentTime!),
                    if (_record.treatmentType != null)
                      _buildInfoRow('치료 유형', _record.treatmentType!),
                    if (_record.diagnosis != null)
                      _buildInfoRow('진단명', _record.diagnosis!),
                  ]),
                  const SizedBox(height: 16),
                  if (_record.symptoms?.isNotEmpty == true)
                    _buildInfoCard('🔍 증상', [
                      _buildInfoRow('관찰된 증상', _record.symptoms!.join(', ')),
                    ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('💊 치료 정보', [
                    if (_record.medicationUsed?.isNotEmpty == true)
                      _buildInfoRow(
                          '사용 약물', _record.medicationUsed!.join(', ')),
                    if (_record.dosageInfo?.isNotEmpty == true)
                      ..._record.dosageInfo!.entries
                          .map((e) => _buildInfoRow('${e.key} 용량', e.value)),
                    if (_record.treatmentMethod != null)
                      _buildInfoRow('치료 방법', _record.treatmentMethod!),
                    if (_record.treatmentDuration != null)
                      _buildInfoRow('치료 기간', '${_record.treatmentDuration}일'),
                    if (_record.withdrawalPeriod != null)
                      _buildInfoRow('휴약기간', '${_record.withdrawalPeriod}일'),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('👨‍⚕️ 담당자 및 비용', [
                    if (_record.veterinarian != null)
                      _buildInfoRow('담당 수의사', _record.veterinarian!),
                    if (_record.treatmentCost != null)
                      _buildInfoRow(
                        '치료 비용',
                        '${_record.treatmentCost!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                      ),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('📊 치료 결과', [
                    if (_record.treatmentResponse != null)
                      _buildInfoRow('치료 반응', _record.treatmentResponse!),
                    if (_record.sideEffects != null)
                      _buildInfoRow('부작용', _record.sideEffects!),
                    if (_record.followUpRequired != null)
                      _buildInfoRow(
                          '추가 치료 필요', _record.followUpRequired! ? '예' : '아니오'),
                    if (_record.followUpDate != null)
                      _buildInfoRow('추가 치료일', _record.followUpDate!),
                  ]),
                  const SizedBox(height: 16),
                  if (_record.notes?.isNotEmpty == true)
                    _buildInfoCard('📝 메모', [
                      _buildInfoRow('특이사항', _record.notes!),
                    ]),
                ],
              ),
            ),
    );
  }
}
