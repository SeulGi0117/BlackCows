import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';

class EstrusRecordProvider with ChangeNotifier {
  List<EstrusRecord> _records = [];

  List<EstrusRecord> get records => _records;

  Future<List<EstrusRecord>> fetchRecords(String cowId, String token) async {
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

        final estrusRecords = data
            .where((record) =>
                record['record_type'] == 'estrus' &&
                record['record_data'] != null)
            .map((json) {
          final recordData = Map<String, dynamic>.from(json['record_data']);
          recordData['cow_id'] = json['cow_id'];
          recordData['record_date'] = json['record_date'];
          recordData['id'] = json['id'];
          return EstrusRecord.fromJson(recordData);
        }).toList();

        _records = estrusRecords;
        notifyListeners();

        debugPrint('📦 불러온 발정 기록 수: ${_records.length}');
        return _records;
      } else {
        debugPrint('발정 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('발정 기록 조회 오류: $e');
      return [];
    }
  }

  // 선택: records 초기화 메서드 (필요 시)
  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addEstrusRecord(EstrusRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/estrus',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('발정 기록 생성 실패: $e');
      return false;
    }
  }
}
