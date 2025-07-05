import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';

class HealthCheckProvider with ChangeNotifier {
  final Logger _logger = Logger('HealthCheckProvider');
  final baseUrl = ApiConfig.baseUrl;
  final Dio _dio = Dio();
  List<HealthCheckRecord> _records = [];

  List<HealthCheckRecord> get records => _records;

  Future<bool> fetchRecords(String cowId, String token) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/health-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null || data is! List) {
          print('⚠️ 서버 응답 데이터가 올바르지 않습니다.');
          return false;
        }

        _records = data
            .where((json) {
              return json['record_type'] == 'health_check';
            })
            .map((json) => HealthCheckRecord.fromJson(json))
            .toList();

        print('✅ 파싱된 건강검진 기록 수: ${_records.length}');
        notifyListeners(); // 데이터가 성공적으로 파싱된 후 호출
        return true;
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ 오류 발생: ${e.message}');
      notifyListeners(); // 오류 발생 시에도 UI 갱신
      return false;
    }
  }

  Future<bool> addRecord(HealthCheckRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('요청 데이터: $baseUrl/records/health-check');
      final response = await dio.post(
        '$baseUrl/records/health-check',
        data: record.toJson(), // 여기로 수정!
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      print('✅ 건강검진 기록 추가 성공: ${response.data}');
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

  Future<HealthCheckRecord?> fetchRecordById(
      String recordId, String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return HealthCheckRecord.fromJson(response.data);
      } else {
        _logger.warning('❌ 단일 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.severe('🚨 단일 기록 조회 중 오류 발생: $e');
      return null;
    }
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
