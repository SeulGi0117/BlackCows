// providers/DetailPage/Feeding/feed_record_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';

class FeedRecordProvider with ChangeNotifier {
  final Logger _logger = Logger('FeedRecordProvider');
  final List<FeedRecord> _records = [];

  List<FeedRecord> get records => _records;

  final Dio _dio = Dio();

  Future<void> fetchRecords(String cowId, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    try {
      final response = await _dio.get(
        '$baseUrl/records/cow/$cowId/feed-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('📡 응답 타입: ${response.headers['content-type']}');
      print('📡 응답 내용: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        _records.clear();
        for (var item in data) {
          try {
            final record = FeedRecord.fromJson(item);
            _records.add(record);
          } catch (e) {
            _logger.warning('❌ 파싱 실패: $e');
          }
        }
        notifyListeners();
      } else {
        _logger.warning('❌ 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('🚨 예외 발생: $e');
      _records.clear();
      notifyListeners();
    }
  }

  Future<bool> addRecord(FeedRecord record, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    try {
      final response = await _dio.post(
        '$baseUrl/records/feed',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final added = FeedRecord.fromJson(response.data);
        _records.add(added);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _logger.severe('❌ 추가 실패: $e');
    }

    return false;
  }

  Future<FeedRecord?> fetchFeedRecordDetail(
      String recordId, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? ''; // ✅ 함수 안에서 안전하게 호출

    try {
      final response = await _dio.get(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return FeedRecord.fromJson(response.data);
      }
    } catch (e) {
      _logger.severe('❌ 사료급여 단건 조회 실패: $e');
    }

    return null;
  }

  Future<bool> updateFeedRecord(
      String recordId, Map<String, dynamic> updateData, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? ''; // ✅ 함수 안에서 선언

    try {
      final response = await _dio.put(
        '$baseUrl/records/$recordId',
        data: updateData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.severe('❌ 사료급여 기록 수정 실패: $e');
      return false;
    }
  }
}
