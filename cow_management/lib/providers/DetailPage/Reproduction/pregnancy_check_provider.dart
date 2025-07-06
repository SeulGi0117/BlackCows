// pregnancy_check_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';

class PregnancyCheckProvider with ChangeNotifier {
  final List<PregnancyCheckRecord> _records = [];
  final Logger _logger = Logger('PregnancyCheckProvider');
  final Dio _dio = Dio();

  List<PregnancyCheckRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _records.clear();

        final dataList = response.data;
        if (dataList == null || dataList is! List) {
          print('⚠️ 응답 데이터가 비어 있거나 리스트 형식이 아님');
          notifyListeners();
          return;
        }

        for (var item in dataList) {
          if (item is Map<String, dynamic> &&
              item['record_type'] == 'pregnancy_check') {
            try {
              final record = PregnancyCheckRecord.fromJson(item);
              _records.add(record);
            } catch (e) {
              print('❌ PregnancyCheckRecord 파싱 오류: $e');
              print('📄 문제된 데이터: $item');
            }
          }
        }

        notifyListeners();
      } else {
        print('❌ 임신감정 기록 조회 실패: HTTP ${response.statusCode}');
        throw Exception('임신감정 기록 조회 실패');
      }
    } on DioException catch (e) {
      print('🚨 Dio 예외 발생: ${e.message}');
      _records.clear();
      notifyListeners();
    } catch (e) {
      print('❌ 예외 발생: $e');
      throw Exception('임신감정 기록 불러오기 실패');
    }
  }

  Future<bool> addRecord(PregnancyCheckRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.post(
        '$baseUrl/records/pregnancy-check',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final added = PregnancyCheckRecord.fromJson(response.data);
        _records.add(added);
        notifyListeners();
        return true;
      } else {
        print('❌ 임신감정 기록 추가 실패: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 임신감정 기록 추가 중 오류 발생: $e');
    }

    return false;
  }

  Future<PregnancyCheckRecord?> fetchRecordById(String id, String token) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/records/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return PregnancyCheckRecord.fromJson(response.data);
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
