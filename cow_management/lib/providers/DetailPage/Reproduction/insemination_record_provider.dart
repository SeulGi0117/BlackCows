import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';

class InseminationRecordProvider with ChangeNotifier {
  List<InseminationRecord> _records = [];

  List<InseminationRecord> get records => _records;

  Future<List<InseminationRecord>> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return [];

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final inseminationRecords = data
            .where((record) =>
                record['record_type'] == 'insemination' &&
                record['record_data'] != null)
            .map((json) {
          final recordData = Map<String, dynamic>.from(json['record_data']);
          recordData['cow_id'] = json['cow_id'];
          recordData['record_date'] = json['record_date'];
          recordData['id'] = json['id'];
          return InseminationRecord.fromJson(recordData);
        }).toList();

        _records = inseminationRecords;
        notifyListeners();

        debugPrint('📦 불러온 인공수정 기록 수: ${_records.length}');
        return _records;
      } else {
        debugPrint('인공수정 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('인공수정 기록 조회 오류: $e');
      return [];
    }
  }

  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addInseminationRecord(InseminationRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/insemination',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('인공수정 기록 생성 실패: $e');
      return false;
    }
  }

  Future<bool> updateRecord(String recordId, InseminationRecord record, String token) async {
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
      debugPrint('인공수정 기록 수정 실패: $e');
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
      debugPrint('인공수정 기록 삭제 실패: $e');
      return false;
    }
  }
} 