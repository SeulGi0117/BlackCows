import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';

class PregnancyCheckProvider with ChangeNotifier {
  List<PregnancyCheckRecord> _records = [];

  List<PregnancyCheckRecord> get records => _records;

  Future<List<PregnancyCheckRecord>> fetchRecords(
      String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return [];

    try {
      print('요청 데이터: $baseUrl/records/cow/$cowId/breeding-records');
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final pregnancyCheckRecords = data
            .where((record) =>
                record['record_type'] == 'pregnancy-check' &&
                record['record_data'] != null)
            .map((json) {
          return PregnancyCheckRecord.fromRecordDataJson(
            json,
            cowId: json['cow_id'],
            recordDate: json['record_date'],
            id: json['id'],
          );
        }).toList();

        _records = pregnancyCheckRecords;
        notifyListeners();

        print('응답: 불러온 임신감정 기록 수: ${_records.length}');
        return _records;
      } else {
        print('임신감정 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('임신감정 기록 조회 오류: $e');
      return [];
    }
  }

  Future<bool> addPregnancyCheckRecord(
      PregnancyCheckRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      print('요청 데이터: $baseUrl/records/pregnancy-check');
      final response = await dio.post(
        '$baseUrl/records/pregnancy-check',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('임신감정 기록 생성 실패: $e');
      return false;
    }
  }

  Future<bool> updateRecord(
      String recordId, PregnancyCheckRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.put(
        '$baseUrl/records/$recordId',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('임신감정 기록 수정 실패: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String recordId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('임신감정 기록 삭제 실패: $e');
      return false;
    }
  }
}
