import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/Health/vaccination_record_provider.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Vaccination/vaccination_edit_page.dart';

class VaccinationDetailPage extends StatefulWidget {
  final String recordId;

  const VaccinationDetailPage({super.key, required this.recordId});

  @override
  State<VaccinationDetailPage> createState() => _VaccinationDetailPageState();
}

class _VaccinationDetailPageState extends State<VaccinationDetailPage> {
  VaccinationRecord? _record;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<VaccinationRecordProvider>();

    try {
      final result = await provider.fetchRecordById(widget.recordId, token);
      if (result != null) {
        setState(() {
          _record = result;
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
        title: Text(
          _isLoading
              ? '백신접종 상세'
              : (_record != null
                  ? '백신접종 상세: ${_record!.recordDate}'
                  : '백신접종 상세'),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildDetailBody(),
    );
  }

  Widget _buildDetailBody() {
    final r = _record!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard('💉 기본 정보', [
          _buildInfoRow('📅 접종 날짜', r.recordDate),
          if (r.vaccinationTime != null)
            _buildInfoRow('⏰ 접종 시간', r.vaccinationTime!),
          if (r.administrator != null)
            _buildInfoRow('👨‍⚕️ 접종자', r.administrator!),
        ]),
        const SizedBox(height: 12),
        _buildSectionCard('🧪 백신 정보', [
          if (r.vaccineName != null) _buildInfoRow('💊 백신명', r.vaccineName!),
          if (r.vaccineType != null) _buildInfoRow('🔬 백신 종류', r.vaccineType!),
          if (r.vaccineManufacturer != null)
            _buildInfoRow('🏭 제조사', r.vaccineManufacturer!),
          if (r.vaccineBatch != null) _buildInfoRow('📦 배치번호', r.vaccineBatch!),
          if (r.expiryDate != null) _buildInfoRow('📅 유효기간', r.expiryDate!),
        ]),
        const SizedBox(height: 12),
        _buildSectionCard('🎯 접종 정보', [
          if (r.dosage != null) _buildInfoRow('💧 접종량', '${r.dosage}ml'),
          if (r.injectionSite != null)
            _buildInfoRow('📍 접종 부위', r.injectionSite!),
          if (r.injectionMethod != null)
            _buildInfoRow('🔧 접종 방법', r.injectionMethod!),
        ]),
        const SizedBox(height: 12),
        if (r.adverseReaction != null || r.reactionDetails != null)
          _buildSectionCard('⚠️ 부작용 정보', [
            if (r.adverseReaction != null)
              _buildInfoRow('🚨 부작용 발생', r.adverseReaction! ? '예' : '아니오'),
            if (r.reactionDetails?.isNotEmpty == true)
              _buildInfoRow('📝 부작용 상세', r.reactionDetails!),
          ]),
        const SizedBox(height: 12),
        _buildSectionCard('📝 추가 정보', [
          if (r.nextVaccinationDue != null)
            _buildInfoRow('📅 다음 접종 예정일', r.nextVaccinationDue!),
          if (r.cost != null)
            _buildInfoRow('💰 비용', '${r.cost?.toStringAsFixed(0)}원'),
          if (r.notes?.isNotEmpty == true) _buildInfoRow('📋 특이사항', r.notes!),
        ]),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VaccinationEditPage(record: _record!),
                ),
              ).then((updated) {
                if (updated == true) {
                  _fetchRecord(); // ✅ 다시 불러오기
                }
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('수정'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmDialog(context),
            icon: const Icon(Icons.delete),
            label: const Text('삭제'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final token = context.read<UserProvider>().accessToken!;
    final provider = context.read<VaccinationRecordProvider>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗑️ 기록 삭제'),
          content: const Text('이 백신접종 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success =
                    await provider.deleteRecord(widget.recordId, token);
                if (success) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('삭제되었습니다')),
                    );
                    Navigator.of(context).pop(true);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제에 실패했습니다')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
