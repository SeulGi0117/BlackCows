import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/health_check_record.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HealthCheckProvider with ChangeNotifier {
  List<HealthCheckRecord> _records = [];

  List<HealthCheckRecord> get records => _records;

  Future<List<HealthCheckRecord>> fetchAndSetRecords(
      String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return [];

    try {
      final response = await dio.get(
        '$baseUrl/records/health-check',
        queryParameters: {'cow_id': cowId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _records = (response.data as List)
          .map((json) => HealthCheckRecord.fromJson(json))
          .toList();

      notifyListeners();
      return _records;
    } catch (e) {
      print('건강검진 기록 불러오기 오류: $e');
      return [];
    }
  }

  Future<bool> addRecord(HealthCheckRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/health-check',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        _records.add(HealthCheckRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('건강검진 기록 추가 오류: $e');
    }
    return false;
  }

  Future<bool> updateRecord(
      String id, HealthCheckRecord updated, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.put(
        '$baseUrl/records/health-check/$id',
        data: updated.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final index = _records.indexWhere((r) => r.id == id);
        if (index != -1) {
          _records[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('건강검진 기록 수정 오류: $e');
    }
    return false;
  }

  Future<bool> deleteRecord(String id, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.delete(
        '$baseUrl/records/health-check/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _records.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('건강검진 기록 삭제 오류: $e');
    }
    return false;
  }
}
