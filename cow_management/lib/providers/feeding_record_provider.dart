import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/feeding_record.dart';

class FeedingRecordProvider with ChangeNotifier {
  List<FeedingRecord> _records = [];

  List<FeedingRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return;

    try {
      final response = await dio.get(
        '$baseUrl/records/feed',
        queryParameters: {'cow_id': cowId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _records = (response.data as List)
          .map((json) => FeedingRecord.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      print('사료 기록 불러오기 오류: $e');
    }
  }

  Future<bool> addRecord(FeedingRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/feed',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        _records.add(FeedingRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('사료 기록 추가 오류: $e');
    }
    return false;
  }

  Future<bool> deleteRecord(String id, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.delete(
        '$baseUrl/records/feeding/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _records.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('사료 기록 삭제 오류: $e');
    }
    return false;
  }
}
