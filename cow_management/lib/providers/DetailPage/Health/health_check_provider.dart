import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HealthCheckProvider with ChangeNotifier {
  List<HealthCheckRecord> _records = [];

  List<HealthCheckRecord> get records => _records;

  Future<List<HealthCheckRecord>> fetchRecords(
      String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) {
      print('⚠️ API_BASE_URL이 설정되지 않았습니다.');
      return [];
    }

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/health-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 건강검진 기록 조회 성공: ${response.statusCode}');
      print('서버 응답: ${response.data}');

      if (response.data == null || response.data is! List) {
        print('⚠️ 서버 응답 데이터가 올바르지 않습니다.');
        return [];
      }

      _records = (response.data as List).where((json) {
        // record_type이 'health_check'인 것만 필터링
        return json['record_type'] == 'health_check';
      }).map((json) {
        // 🧸 record_data 안전하게 처리
        Map<String, dynamic> recordData = {};
        if (json['record_data'] != null &&
            json['record_data'] is Map<String, dynamic>) {
          recordData = Map<String, dynamic>.from(json['record_data']);
        }

        // 다른 값들 수동으로 추가해주기
        recordData['id'] = json['id'];
        recordData['cow_id'] = json['cow_id'];
        recordData['record_date'] = json['record_date'];

        return HealthCheckRecord.fromJson(recordData);
      }).toList();

      notifyListeners();
      return _records;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        print('🚨 서버 내부 오류 (500): 백엔드 서버에 문제가 있습니다.');
        print('서버 응답: ${e.response?.data}');
        // 서버 오류 시 빈 리스트 반환하여 앱이 계속 작동하도록 함
        _records = [];
        notifyListeners();
        return [];
      } else if (e.response?.statusCode == 404) {
        print('📭 건강검진 기록이 없습니다 (404)');
        _records = [];
        notifyListeners();
        return [];
      } else {
        print('❌ 건강검진 기록 불러오기 네트워크 오류: ${e.message}');
        return [];
      }
    } catch (e) {
      print('❌ 건강검진 기록 불러오기 예상치 못한 오류: $e');
      return [];
    }
  }

  Future<void> fetchFilteredRecords(
      String cowId, String token, String recordType) async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

      final response = await dio.get(
        '$apiUrl/records/cow/$cowId',
        queryParameters: {'record_type': recordType},
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        _records = data.map((json) {
          final recordData = json['record_data'] as Map<String, dynamic>;
          recordData['id'] = json['id'];
          recordData['record_date'] = json['record_date'];
          recordData['cow_id'] = cowId;
          return HealthCheckRecord.fromJson(recordData);
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
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/health-check',
        data: record.toJson(), // ✅ 여기로 수정!
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
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

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
