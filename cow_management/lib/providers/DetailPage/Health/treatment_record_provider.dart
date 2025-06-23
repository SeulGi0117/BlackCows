import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';

class TreatmentRecordProvider with ChangeNotifier {
  final List<TreatmentRecord> _records = [];

  List<TreatmentRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId',
        queryParameters: {'record_type': 'treatment'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _records.clear();
        for (var item in response.data) {
          final data = item['record_data'];
          data['cow_id'] = cowId;
          data['record_date'] = item['record_date'];
          _records.add(TreatmentRecord.fromJson(data));
        }
        notifyListeners();
      }
    } catch (e) {
      throw Exception('치료 기록 불러오기 실패: $e');
    }
  }

  Future<bool> addRecord(TreatmentRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final response = await dio.post(
        '$baseUrl/records',
        data: {
          'cow_id': record.cowId,
          'record_type': 'treatment',
          'record_date': record.recordDate,
          'record_data': record.toRecordDataJson(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        _records.add(TreatmentRecord.fromJson(response.data['record_data']));
        notifyListeners();
        return true; // ✅ 성공 시 true 반환
      }
    } catch (e) {
      print('치료 기록 추가 실패: $e');
    }

    return false; // ❌ 실패 시 false 반환
  }
}
