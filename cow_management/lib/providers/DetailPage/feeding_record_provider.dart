// providers/DetailPage/Feeding/feed_record_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/utils/api_config.dart';

class FeedRecordProvider with ChangeNotifier {
  final Logger _logger = Logger('FeedRecordProvider');
  final List<FeedRecord> _records = [];

  List<FeedRecord> get records => _records;

  final Dio _dio = Dio();
  final String baseUrl = ApiConfig.baseUrl;

  Future<void> fetchRecords(String cowId, String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/records/cow/$cowId/feed-records',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      print('🐮 응답 상태 코드: ${response.statusCode}');
      print('📦 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // 응답이 List인지 Map(data 속성 포함)인지 자동 판별
        final recordsJson = data is List
            ? data
            : (data is Map && data['data'] is List)
                ? data['data']
                : [];

        _records.clear();
        for (var json in recordsJson) {
          final record = FeedRecord.fromJson(json);
          print('✅ record.id: ${record.id}');
          _records.add(record);
        }

        notifyListeners();
      } else {
        throw Exception('응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 사료 기록 불러오기 실패: $e');
      throw Exception('사료 기록 불러오기 실패: $e');
    }
  }

  Future<bool> addRecord(FeedRecord record, String token) async {
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

  Future<void> updateRecord(
      String recordId, Map<String, dynamic> updatedData, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    // GET과 동일하게 recordId를 URL에 사용
    final url = '$baseUrl/records/$recordId';

    // 서버가 요구하는 구조로 payload 생성
    final payload = <String, dynamic>{
      if (updatedData['record_date'] != null)
        'record_date': updatedData['record_date'],
      if (updatedData['title'] != null) 'title': updatedData['title'],
      if (updatedData['description'] != null)
        'description': updatedData['description'],
      // 상세 필드는 반드시 record_data로 감싸서!
      if (updatedData['record_data'] != null)
        'record_data': updatedData['record_data']
      else
        'record_data': updatedData, // 이미 감싸져 있지 않으면 전체를 감쌈
    };

    try {
      final response = await _dio.put(
        url,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _logger.info('✅ 수정 성공: $recordId');
      } else {
        _logger.warning('❌ 수정 실패: ${response.statusCode} - ${response.data}');
      }
    } catch (e, s) {
      _logger.severe('🚨 수정 중 오류 발생: $e', e, s);
    }
  }

  Future<void> deleteRecord(String recordId, String token) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    try {
      final response = await _dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _logger.info('✅ 삭제 성공: $recordId');
        // 목록 새로고침 등 후처리
      } else {
        _logger.warning('❌ 삭제 실패: ${response.statusCode}');
      }
    } catch (e, s) {
      _logger.severe('🚨 삭제 중 오류 발생: $e', e, s);
    }
  }
}
