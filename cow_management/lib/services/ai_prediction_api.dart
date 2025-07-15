import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/services/dio_client.dart';

final Dio _dio = DioClient().dio;

// 착유량 예측
Future<double?> milkYieldPrediction({
   required int milking_frequency,
   required double conductivity,
   required double temperature,
   required double fat_percentage,
   required double protein_percentage,
   required double concentrate_intake,
   required int milking_month,
   required int milking_day_of_week,    
}) async {
  try {
    final response = await _dio.post('/ai/milk-yield/predict', data: {
      'milking_frequency': milking_frequency,
      'conductivity': conductivity,
      'temperature': temperature,
      'fat_percentage': fat_percentage,
      'protein_percentage': protein_percentage,
      'concentrate_intake': concentrate_intake,
      'milking_month': milking_month,
      'milking_day_of_week': milking_day_of_week,
    });
    // double로 변환해서 반환
    return (response.data['predicted_milk_yield'] as num?)?.toDouble();
  } catch (e) {
    print('❌ 착유량 예측 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return null;
  }
}

/// 다중 젖소 착유량 예측 (배치)
Future<Map<String, dynamic>?> milkYieldBatchPrediction({
  required List<Map<String, dynamic>> predictions,
  String? batchName,
}) async {
  try {
    final response = await _dio.post('/ai/milk-yield/batch-predict', data: {
      'predictions': predictions,
      'batch_name': batchName,
    });
    return response.data as Map<String, dynamic>;
  } catch (e) {
    print('❌ 착유량 배치 예측 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return null;
  }
}
