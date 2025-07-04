import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/utils/api_config.dart';

class PregnancyCheckDetailPage extends StatefulWidget {
  final String recordId;

  const PregnancyCheckDetailPage({super.key, required this.recordId});

  @override
  State<PregnancyCheckDetailPage> createState() =>
      _PregnancyCheckDetailPageState();
}

class _PregnancyCheckDetailPageState extends State<PregnancyCheckDetailPage> {
  PregnancyCheckRecord? _record;
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
          _record = PregnancyCheckRecord.fromJson(data);
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
        title: const Text('임신감정 상세 정보'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _record == null
                  ? const Center(child: Text('기록이 존재하지 않습니다.'))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          _buildItem('감정일', _record?.recordDate),
                          _buildItem('감정 방법', _record?.checkMethod),
                          _buildItem('감정 결과', _record?.checkResult),
                          _buildItem(
                            '임신 단계',
                            (_record!.pregnancyStage > 0)
                                ? '${_record!.pregnancyStage}일차'
                                : '정보 없음',
                          ),
                          _buildItem('태아 상태', _record?.fetusCondition),
                          _buildItem('분만 예정일', _record?.expectedCalvingDate),
                          _buildItem('수의사명', _record?.veterinarian),
                          _buildItem(
                            '감정 비용',
                            (_record!.checkCost > 0)
                                ? '${_record!.checkCost} 원'
                                : '미입력',
                          ),
                          _buildItem('다음 감정일', _record?.nextCheckDate),
                          _buildItem('추가 관리사항', _record?.additionalCare),
                          _buildItem('메모', _record?.notes),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              (value != null && value.isNotEmpty) ? value : '없음',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
