import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/utils/api_config.dart';

class HealthCheckProvider with ChangeNotifier {
  List<HealthCheckRecord> _records = [];

  List<HealthCheckRecord> get records => _records;

  Future<bool> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

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

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 500) {
      print('🚨 서버 내부 오류 (500)');
    } else if (e.response?.statusCode == 404) {
      print('📭 건강검진 기록이 없습니다 (404)');
    } else {
      print('❌ 네트워크 오류: ${e.message}');
    }
    _records = [];
    notifyListeners();
  }

  Future<void> fetchFilteredRecords(
      String cowId, String token, String recordType) async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final apiUrl = ApiConfig.baseUrl;

      print('요청 데이터: $apiUrl/records/cow/$cowId');
      final response = await dio.get(
        '$apiUrl/records/cow/$cowId',
        queryParameters: {'record_type': recordType},
      );
      print('✅ 건강검진 기록 필터링 조회 성공: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as List;
        _records = data.map((json) {
          // 전체 JSON을 그대로 전달
          return HealthCheckRecord.fromJson(json);
        }).toList();

        notifyListeners();
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('건강검진 기록 불러오기 오류: $e');
      rethrow;
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

  Future<bool> updateRecord(
      String id, HealthCheckRecord updated, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.put(
        '$baseUrl/records/$id',
        data: {
          'record_date': updated.recordDate,
          'record_data': updated.toJson(),
        },
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
