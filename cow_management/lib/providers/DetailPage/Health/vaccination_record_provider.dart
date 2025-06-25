import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';

class VaccinationRecordProvider with ChangeNotifier {
  final List<VaccinationRecord> _records = [];

  List<VaccinationRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/vaccination-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _records.clear();
        for (var item in response.data) {
          final data = item['record_data']; // record_data만 파싱
          data['record_date'] = item['record_date']; // 날짜도 넣어줌
          data['cow_id'] = cowId;
          _records.add(VaccinationRecord.fromJson(data));
        }
        notifyListeners();
      }
    } catch (e) {
      throw Exception('백신접종 기록 불러오기 실패: $e');
    }
  }

  Future<void> addRecord(VaccinationRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final response = await dio.post(
        '$baseUrl/records/vaccination',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        _records.add(VaccinationRecord.fromJson(response.data['record_data']));
        notifyListeners();
      }
    } catch (e) {
      throw Exception('백신접종 기록 추가 실패: $e');
    }
  }
}
