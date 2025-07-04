// pregnancy_check_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/Reproduction/pregnancy_check_record.dart';
import 'package:cow_management/utils/api_config.dart';

class PregnancyCheckProvider with ChangeNotifier {
  final List<PregnancyCheckRecord> _records = [];

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

  Future<PregnancyCheckRecord?> fetchPregnancyCheckDetail(
      String recordId, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;
    print("📦 요청할 recordId: $recordId");

    try {
      final response = await dio.get(
        '$baseUrl/api/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return PregnancyCheckRecord.fromJson(response.data);
      }
    } catch (e) {
      print('❌ 임신감정 단건 조회 실패: $e');
    }

    return null;
  }

  Future<bool> updatePregnancyCheckRecord(
      String recordId, Map<String, dynamic> updateData, String token) async {
    final dio = Dio();
    final baseUrl = ApiConfig.baseUrl;

    try {
      final response = await dio.put(
        '$baseUrl/$recordId',
        data: updateData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ 임신감정 기록 수정 실패: $e');
      return false;
    }
  }
}
