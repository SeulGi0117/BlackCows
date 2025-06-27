import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

class WeightRecordProvider with ChangeNotifier {
  final List<WeightRecord> _records = [];

  List<WeightRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) {
      print('⚠️ API_BASE_URL이 설정되지 않았습니다.');
      return;
    }

    try {
      print('🔄 체중 기록 조회 시작: $baseUrl/records/cow/$cowId/weight-records');
      
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/weight-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 체중 기록 조회 응답: ${response.statusCode}');
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
        print('📊 전체 기록 수: ${dataList.length}');

        int weightCount = 0;
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            try {
              // 서버 응답 전체를 모델에 전달
              final record = WeightRecord.fromJson(Map<String, dynamic>.from(item));
              
              _records.add(record);
              weightCount++;
              print('✅ 체중 기록 파싱 성공: ${record.weight}kg');
            } catch (e) {
              // 개별 파싱 실패해도 계속 진행
              print('! 체중 기록 파싱 오류: $e');
              print('📄 문제가 된 데이터: $item');
            }
          }
        }
        
        print('✅ 체중 기록 필터링 완료: $weightCount개');
        notifyListeners();
      } else {
        print('❌ 예상치 못한 응답 코드: ${response.statusCode}');
        throw Exception('체중 기록 조회 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 Dio 오류 발생:');
      print('   - 오류 타입: ${e.type}');
      print('   - 상태 코드: ${e.response?.statusCode}');
      print('   - 오류 메시지: ${e.message}');
      
      if (e.response?.statusCode == 500) {
        print('🚨 서버 내부 오류 (500): 백엔드 서버에 문제가 있습니다.');
        _records.clear();
        notifyListeners();
        return;
      }
      
      if (e.response?.statusCode == 404) {
        print('📭 체중 기록이 없습니다 (404)');
        _records.clear();
        notifyListeners();
        return;
      }
      
      throw Exception('체중 기록 불러오기 실패: $e');
    } catch (e) {
      print('❌ 일반 오류: $e');
      throw Exception('체중 기록 불러오기 실패: $e');
    }
  }

  Future<void> addRecord(WeightRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    try {
      final requestData = {
        'cow_id': record.cowId,
        'record_date': record.recordDate,
        'title': '체중측정 기록',
        'description': record.notes?.isNotEmpty == true ? record.notes : '체중측정 실시',
        'record_data': record.toRecordDataJson(),
      };

      print('🔄 체중측정 기록 저장 요청: $requestData');

      final response = await dio.post(
        '$baseUrl/records/weight',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 체중측정 기록 저장 응답: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        _records.add(WeightRecord.fromJson(response.data));
        notifyListeners();
      }
    } catch (e) {
      print('❌ 체중측정 기록 추가 실패: $e');
      throw Exception('체중 기록 추가 실패: $e');
    }
  }
}
