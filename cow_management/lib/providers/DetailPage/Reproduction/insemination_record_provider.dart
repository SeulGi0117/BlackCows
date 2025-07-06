import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';

class InseminationRecordProvider with ChangeNotifier {
  List<InseminationRecord> _records = [];
  final Logger _logger = Logger('InseminationRecordProvider');
  final Dio _dio = Dio();

  List<InseminationRecord> get records => _records;

  Future<List<InseminationRecord>> fetchRecords(
      String cowId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('[🐮 DEBUG] Response status: ${response.statusCode}');
      print('[🐮 DEBUG] Response data: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final inseminationRecords = data
            .where((record) => record['record_type'] == 'insemination')
            .map((json) {
              try {
                return InseminationRecord.fromJson(
                    Map<String, dynamic>.from(json));
              } catch (e) {
                print('! 인공수정 파싱 오류: $e');
                print('📄 문제가 된 데이터: $json');
                return null;
              }
            })
            .where((record) => record != null)
            .cast<InseminationRecord>()
            .toList();

        _records = inseminationRecords;
        notifyListeners();

        debugPrint('📦 불러온 인공수정 기록 수: ${_records.length}');
        return _records;
      } else {
        debugPrint('인공수정 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('인공수정 기록 조회 오류: $e');
      return [];
    }
  }

  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addInseminationRecord(
      InseminationRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final requestData = record.toJson(); // ✅ 핵심 수정 포인트

      final response = await dio.post(
        '$baseUrl/records/insemination',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('🔄 인공수정 기록 저장 요청: $requestData');
      print('✅ 인공수정 기록 저장 응답: ${response.statusCode}');

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('인공수정 기록 생성 실패: $e');
      return false;
    }
  }

  Future<InseminationRecord?> fetchRecordById(String id, String token) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/records/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return InseminationRecord.fromJson(response.data);
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
