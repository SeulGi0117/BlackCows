import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/milking_record.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MilkingRecordProvider');

class MilkingRecordProvider with ChangeNotifier {
  final List<MilkingRecord> _records = [];
  final Dio _dio = Dio();
  final String baseUrl = ApiConfig.baseUrl;

  List<MilkingRecord> get records => List.unmodifiable(_records);
  Future<void> fetchRecords(String cowId, String token,
      {int limit = 50}) async {
    try {
      final url = '$baseUrl/records/milking/recent';
      print('🛰️ 요청 URL: $url');
      print('🐮 cowId: $cowId');
      print('🪪 토큰: $token');

      final response = await _dio.get(
        url,
        queryParameters: {'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        _records.clear();

        for (var json in data) {
          if (json['cow_id'] == cowId) {
            _records.add(MilkingRecord.fromJson(json));
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('❌ 에러 전체 출력: $e');
      throw Exception('📦 소별 최근 기록 불러오기 실패: $e');
    }
  }

  Future<void> addRecord(MilkingRecord record, String token) async {
    try {
      final body = {
        'record_type': 'milking',
        'cow_id': record.cowId,
        'record_date': record.recordDate,
        'record_data': record.toJson(), // 측정값들은 이 안에!
      };

      final response = await _dio.post(
        '$baseUrl/records/milking',
        data: body,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _records.add(record);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('착유 기록 추가 실패: $e');
    }
  }

  Future<MilkingRecord?> fetchRecordById(String id, String token) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/records/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return MilkingRecord.fromJson(response.data);
      } else {
        _logger.warning('상세 조회 실패: ${response.statusCode}');
      }
    } catch (e, s) {
      _logger.severe('상세 조회 중 오류 발생: $e', e, s);
    }
    return null;
  }

  Future<bool> updateRecord(
      String recordId, Map<String, dynamic> updatedData, String token) async {
    final url = '${ApiConfig.baseUrl}/records/$recordId';

    final payload = <String, dynamic>{
      if (updatedData['record_date'] != null)
        'record_date': updatedData['record_date'],
      if (updatedData['title'] != null) 'title': updatedData['title'],
      if (updatedData['description'] != null)
        'description': updatedData['description'],
      'record_data': updatedData['record_data'] ?? updatedData,
    };

    try {
      _logger.info('📡 요청 URL: $url');
      _logger.info('📦 요청 데이터: $payload');
      final response = await _dio.put(
        url,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _logger.info('✅ 수정 성공: $recordId');
        return true;
      } else {
        _logger.warning('❌ 수정 실패: ${response.statusCode} - ${response.data}');
        return false;
      }
    } catch (e, s) {
      _logger.severe('🚨 수정 중 오류 발생: $e', e, s);
      return false;
    }
  }

  Future<bool> deleteRecord(String id, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.delete(
        '$baseUrl/records/$id',
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
