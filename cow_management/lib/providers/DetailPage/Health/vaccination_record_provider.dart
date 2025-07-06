import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';

class VaccinationRecordProvider with ChangeNotifier {
  final List<VaccinationRecord> _records = [];
  final Logger _logger = Logger('VaccinationRecordProvider');
  final Dio _dio = Dio();
  List<VaccinationRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      print('🔄 백신접종 기록 조회 시작: $baseUrl/records/cow/$cowId/health-records');

      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/health-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 백신접종 기록 조회 응답: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        _records.clear();

        if (response.data == null) {
          print('⚠️ 응답 데이터가 null입니다.');
          notifyListeners();
          return;
        }

        if (response.data is! List) {
          print('⚠️ 응답 데이터가 List 형태가 아닙니다: ${response.data.runtimeType}');
          notifyListeners();
          return;
        }

        final List<dynamic> dataList = response.data as List<dynamic>;
        print('📊 전체 건강 기록 수: ${dataList.length}');

        int vaccinationCount = 0;
        for (var item in dataList) {
          if (item is Map<String, dynamic> &&
              item['record_type'] == 'vaccination') {
            try {
              // 전체 JSON을 그대로 전달 (key_values 포함)
              _records.add(
                  VaccinationRecord.fromJson(Map<String, dynamic>.from(item)));
              vaccinationCount++;
            } catch (e) {
              print('! 백신접종 기록 파싱 오류: $e');
              print('📄 문제가 된 데이터: $item');
            }
          }
        }

        print('✅ 백신접종 기록 필터링 완료: $vaccinationCount개');
        notifyListeners();
      } else {
        print('❌ 예상치 못한 응답 코드: ${response.statusCode}');
        throw Exception('백신접종 기록 조회 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 Dio 오류 발생:');
      print('   - 오류 타입: ${e.type}');
      print('   - 상태 코드: ${e.response?.statusCode}');
      print('   - 오류 메시지: ${e.message}');

      if (e.response?.statusCode == 500) {
        print('🚨 서버 내부 오류 (500): 백엔드 서버에 문제가 있습니다.');
        print('서버 응답: ${e.response?.data}');

        // 500 오류 시에도 빈 목록으로 처리하여 앱이 크래시되지 않도록 함
        _records.clear();
        notifyListeners();
        return;
      }

      if (e.response?.statusCode == 404) {
        print('📭 백신접종 기록이 없습니다 (404)');
        _records.clear();
        notifyListeners();
        return;
      }

      throw Exception('백신접종 기록 불러오기 실패: $e');
    } catch (e) {
      print('❌ 일반 오류: $e');
      throw Exception('백신접종 기록 불러오기 실패: $e');
    }
  }

  Future<bool> addRecord(VaccinationRecord record, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.post(
        '$baseUrl/records/vaccination',
        data: record.toJson(), // ✅ 통일된 방식으로 전송
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      print('✅ 백신접종 기록 추가 성공: ${response.data}');

      if (response.statusCode == 201) {
        _records.add(VaccinationRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('❌ 백신접종 기록 추가 실패: $e');
    }
    return false;
  }

  Future<VaccinationRecord?> fetchRecordById(String id, String token) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/records/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return VaccinationRecord.fromJson(response.data);
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
