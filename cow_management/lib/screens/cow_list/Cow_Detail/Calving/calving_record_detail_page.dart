import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:cow_management/models/Detail/Reproduction/calving_record.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/utils/api_config.dart';

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
          _record = CalvingRecord.fromJson(data); // record_data 포함 전체 파싱
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

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분만 상세 정보'),
        backgroundColor: const Color(0xFF795548),
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
                          _buildItem('기록일', _record?.recordDate),
                          _buildItem('시작 시간', _record?.calvingStartTime),
                          _buildItem('종료 시간', _record?.calvingEndTime),
                          _buildItem('난이도', _record?.calvingDifficulty),
                          _buildItem('송아지 수', _record?.calfCount?.toString()),
                          _buildItem('태반 배출 여부',
                              _record!.placentaExpelled == true ? '예' : '아니오'),
                          _buildItem(
                              '태반 배출 시간', _record?.placentaExpulsionTime),
                          _buildItem(
                              '수의사 호출 여부',
                              _record!.veterinarianCalled == true
                                  ? '예'
                                  : '아니오'),
                          _buildItem('비유 시작일', _record?.lactationStart),
                          _buildItem('모우 상태', _record?.damCondition),
                          _buildItem('비고', _record?.notes),
                          const SizedBox(height: 16),
                          if (_record!.calfGender != null &&
                              _record!.calfGender!.isNotEmpty)
                            _buildItem(
                                '송아지 성별', _record!.calfGender!.join(', ')),
                          if (_record!.calfWeight != null &&
                              _record!.calfWeight!.isNotEmpty)
                            _buildItem(
                                '송아지 체중',
                                _record!.calfWeight!
                                    .map((w) => '${w}kg')
                                    .join(', ')),
                          if (_record!.calfHealth != null &&
                              _record!.calfHealth!.isNotEmpty)
                            _buildItem(
                                '송아지 건강', _record!.calfHealth!.join(', ')),
                          if (_record!.complications != null &&
                              _record!.complications!.isNotEmpty)
                            _buildItem(
                                '합병증', _record!.complications!.join(', ')),
                        ],
                      ),
                    ),
    );
  }
}
