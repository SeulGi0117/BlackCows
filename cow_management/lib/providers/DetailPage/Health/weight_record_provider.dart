import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:cow_management/models/Detail/Health/weight_record_model.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';

class WeightRecordProvider with ChangeNotifier {
  List<WeightRecord> _records = [];
  final Logger _logger = Logger('WeightRecordProvider');
  final Dio _dio = Dio();
  List<WeightRecord> get records => _records;

  Future<List<WeightRecord>> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('요청 데이터: $baseUrl/records/cow/$cowId/weight-records');
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/weight-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 체중 기록 조회 성공: ${response.statusCode}');
      print('응답: ${response.data}');

      if (response.data == null || response.data is! List) {
        print('⚠️ 서버 응답 데이터가 올바르지 않습니다.');
        return [];
      }

      _records.clear();

      final dataList = response.data as List;
      _records = dataList.where((json) {
        return json['record_type'] == 'weight';
      }).map((json) {
        return WeightRecord.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      print('✅ 파싱된 체중 기록 수: ${_records.length}');
      for (var record in _records) {
        print(
            '기록: 날짜=${record.recordDate}, 체중=${record.weight}kg, BCS=${record.bodyConditionScore}');
      }

      notifyListeners();
      return _records;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        print('🚨 서버 내부 오류 (500): 백엔드 서버에 문제가 있습니다.');
        print('서버 응답: ${e.response?.data}');
        _records = [];
        notifyListeners();
        return [];
      } else if (e.response?.statusCode == 404) {
        print('📭 체중 기록이 없습니다 (404)');
        _records = [];
        notifyListeners();
        return [];
      } else {
        print('❌ 체중 기록 불러오기 네트워크 오류: ${e.message}');
        return [];
      }
    } catch (e) {
      print('❌ 체중 기록 불러오기 예상치 못한 오류: $e');
      return [];
    }
  }

  Future<bool> addRecord(WeightRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('요청 데이터: $baseUrl/records/weight');
      final response = await dio.post(
        '$baseUrl/records/weight',
        data: record.toJson(), // ✅ 통일된 toJson 사용
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ 체중 기록 추가 성공: ${response.data}');
      if (response.statusCode == 201) {
        _records.add(WeightRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('❌ 체중 기록 추가 실패: $e');
    }

    return false;
  }

  Future<WeightRecord?> fetchRecordById(String id, String token) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/records/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return WeightRecord.fromJson(response.data);
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
