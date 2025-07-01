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
      print('요청 데이터: $baseUrl/records/cow/$cowId/breeding-records');
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print('응답: $response');
        final List<dynamic> data = response.data;

        final calvingRecords = data
            .where((record) =>
                record['record_type'] == 'calving' &&
                record['record_data'] != null)
            .map((json) {
          final recordData = Map<String, dynamic>.from(json['record_data']);
          recordData['cow_id'] = json['cow_id'];
          recordData['record_date'] = json['record_date'];
          recordData['id'] = json['id'];
          return CalvingRecord.fromJson(recordData);
        }).toList();

        _records = calvingRecords;
        notifyListeners();

        print('📦 불러온 분만 기록 수: ${_records.length}');
        return _records;
      } else {
        print('분만 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('분만 기록 조회 오류: $e');
      return [];
    }
  }

  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addCalvingRecord(CalvingRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('요청 데이터: $baseUrl/records/calving');
      final response = await dio.post(
        '$baseUrl/records/calving',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('응답: $response');
      return response.statusCode == 201;
    } catch (e) {
      print('분만 기록 생성 실패: $e');
      return false;
    }
  }

  Future<bool> updateRecord(String recordId, CalvingRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('요청 데이터: $baseUrl/records/$recordId');
      final response = await dio.put(
        '$baseUrl/records/$recordId',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('응답: $response');
      return response.statusCode == 200;
    } catch (e) {
      print('분만 기록 수정 실패: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String recordId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('요청 데이터: $baseUrl/records/$recordId');
      final response = await dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('응답: $response');
      return response.statusCode == 200;
    } catch (e) {
      print('분만 기록 삭제 실패: $e');
      return false;
    }
  }
} 