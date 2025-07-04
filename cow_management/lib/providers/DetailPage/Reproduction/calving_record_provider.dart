import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Reproduction/calving_record.dart';
import 'package:cow_management/utils/api_config.dart';

class CalvingRecordProvider with ChangeNotifier {
  List<CalvingRecord> _records = [];

  List<CalvingRecord> get records => _records;

  Future<List<CalvingRecord>> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('🔄 분만 기록 조회 시작: $baseUrl/records/cow/$cowId/breeding-records');

      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 분만 기록 조회 응답: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📊 전체 번식 기록 수: ${data.length}');

        final calvingRecords = data
            .where((record) => record['record_type'] == 'calving')
            .map((json) {
              try {
                return CalvingRecord.fromJson(Map<String, dynamic>.from(json));
              } catch (e) {
                print('❌ 분만 기록 파싱 오류: $e');
                print('📄 문제가 된 데이터: $json');
                return null;
              }
            })
            .where((record) => record != null)
            .cast<CalvingRecord>()
            .toList();

        _records = calvingRecords;
        notifyListeners();

        print('📦 불러온 분만 기록 수: ${_records.length}');
        return _records;
      } else {
        print('❌ 분만 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 분만 기록 조회 오류: $e');
      return [];
    }
  }

  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addCalvingRecord(CalvingRecord record, String? token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final requestData = {
        'cow_id': record.cowId,
        'record_date': record.recordDate,
        'title': '분만 기록',
        'description':
            record.notes?.isNotEmpty == true ? record.notes : '분만 진행',
        'record_data': record.toJson(),
      };

      print('🔄 분만 기록 저장 요청: $requestData');

      final response = await dio.post(
        '$baseUrl/records/calving',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 분만 기록 저장 응답: ${response.statusCode}');

      if (response.statusCode == 201) {
        _records.add(CalvingRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 분만 기록 생성 실패: $e');
      return false;
    }
  }

  Future<bool> updateRecord(
      String recordId, CalvingRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final requestData = {
        'cow_id': record.cowId,
        'record_date': record.recordDate,
        'title': '분만 기록 수정',
        'description':
            record.notes?.isNotEmpty == true ? record.notes : '분만 기록 업데이트',
        'record_data': record.toJson(),
      };

      print('🛠️ 분만 기록 수정 요청: $requestData');

      final response = await dio.put(
        '$baseUrl/records/$recordId',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 분만 기록 수정 응답: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ 분만 기록 수정 실패: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String recordId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('🗑️ 분만 기록 삭제 요청: $baseUrl/records/$recordId');

      final response = await dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 분만 기록 삭제 응답: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ 분만 기록 삭제 실패: $e');
      return false;
    }
  }
}
