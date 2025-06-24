import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

class WeightRecordProvider with ChangeNotifier {
  final List<WeightRecord> _records = [];

  List<WeightRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId',
        queryParameters: {'record_data': 'weight'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _records.clear();
        for (var item in response.data) {
          final data = item['record_data'];
          data['record_date'] = item['record_date'];
          data['cow_id'] = cowId;
          _records.add(WeightRecord.fromJson(data));
        }
        notifyListeners();
      }
    } catch (e) {
      throw Exception('체중 기록 불러오기 실패: $e');
    }
  }

  Future<void> addRecord(WeightRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final response = await dio.post(
        '$baseUrl/records',
        data: {
          'cow_id': record.cowId,
          'record_type': 'weight',
          'record_date': record.recordDate,
          'record_data': record.toRecordDataJson(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final data = response.data['record_data'];
        data['record_date'] = record.recordDate;
        data['cow_id'] = record.cowId;
        _records.add(WeightRecord.fromJson(data));
        notifyListeners();
      }
    } catch (e) {
      throw Exception('체중 기록 추가 실패: $e');
    }
  }
}
