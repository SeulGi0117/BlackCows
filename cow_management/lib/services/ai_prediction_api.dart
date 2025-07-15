import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/services/dio_client.dart';

final Dio _dio = DioClient().dio;

// 착유량 예측 결과 모델
class MilkYieldPredictionResult {
  final double? predictedYield;
  final double? confidence;
  final String? errorMessage;
  final bool isSuccess;

  MilkYieldPredictionResult({
    this.predictedYield,
    this.confidence,
    this.errorMessage,
    required this.isSuccess,
  });
}

// 착유량 예측
Future<MilkYieldPredictionResult> milkYieldPrediction({
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
    // 입력값 검증
    final validationError = _validateInputs(
      milking_frequency: milking_frequency,
      conductivity: conductivity,
      temperature: temperature,
      fat_percentage: fat_percentage,
      protein_percentage: protein_percentage,
      concentrate_intake: concentrate_intake,
      milking_month: milking_month,
      milking_day_of_week: milking_day_of_week,
    );
    
    if (validationError != null) {
      return MilkYieldPredictionResult(
        isSuccess: false,
        errorMessage: validationError,
      );
    }

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
    
    // 예측값과 신뢰도(%)를 반환
    final predictedYield = (response.data['predicted_milk_yield'] as num?)?.toDouble();
    final confidence = (response.data['confidence'] as num?)?.toDouble();
    
    return MilkYieldPredictionResult(
      predictedYield: predictedYield,
      confidence: confidence,
      isSuccess: true,
    );
  } catch (e) {
    print('❌ 착유량 예측 실패: $e');
    
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
      
      // HTTP 상태 코드별 에러 메시지
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      switch (statusCode) {
        case 400:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: '잘못된 요청입니다. 입력값을 확인해주세요.',
          );
        case 422:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: _parse422Error(errorData),
          );
        case 500:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          );
        case 503:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: 'AI 서비스가 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
          );
        default:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.',
          );
      }
    }
    
    return MilkYieldPredictionResult(
      isSuccess: false,
      errorMessage: '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.',
    );
  }
}

// 입력값 검증
String? _validateInputs({
  required int milking_frequency,
  required double conductivity,
  required double temperature,
  required double fat_percentage,
  required double protein_percentage,
  required double concentrate_intake,
  required int milking_month,
  required int milking_day_of_week,
}) {
  // 필수값 검증
  if (milking_frequency <= 0) {
    return '착유 횟수는 1회 이상이어야 합니다.';
  }
  if (milking_frequency > 10) {
    return '착유 횟수는 10회 이하여야 합니다.';
  }
  
  if (conductivity <= 0) {
    return '전도율은 0보다 큰 값이어야 합니다.';
  }
  if (conductivity > 20) {
    return '전도율은 20 mS/cm 이하여야 합니다.';
  }
  
  if (temperature < -50 || temperature > 100) {
    return '환경 온도는 -50°C ~ 100°C 범위여야 합니다.';
  }
  
  if (fat_percentage <= 0 || fat_percentage > 20) {
    return '유지방 비율은 0% ~ 20% 범위여야 합니다.';
  }
  
  if (protein_percentage <= 0 || protein_percentage > 10) {
    return '유단백 비율은 0% ~ 10% 범위여야 합니다.';
  }
  
  if (concentrate_intake <= 0) {
    return '사료 섭취량은 0보다 큰 값이어야 합니다.';
  }
  if (concentrate_intake > 100) {
    return '사료 섭취량은 100kg 이하여야 합니다.';
  }
  
  if (milking_month < 1 || milking_month > 12) {
    return '착유 측정월은 1월 ~ 12월 범위여야 합니다.';
  }
  
  if (milking_day_of_week < 0 || milking_day_of_week > 6) {
    return '착유 측정요일은 월요일(0) ~ 일요일(6) 범위여야 합니다.';
  }
  
  return null;
}

// 422 에러 상세 파싱
String _parse422Error(dynamic errorData) {
  if (errorData == null) {
    return '입력값이 올바르지 않습니다. 모든 필드를 확인해주세요.';
  }
  
  try {
    if (errorData is Map<String, dynamic>) {
      final detail = errorData['detail'];
      if (detail is List) {
        final errors = detail.map((e) {
          if (e is Map<String, dynamic>) {
            final field = e['loc']?.last?.toString() ?? '알 수 없는 필드';
            final message = e['msg']?.toString() ?? '값이 올바르지 않습니다';
            return '$field: $message';
          }
          return e.toString();
        }).join('\n');
        return '입력값 오류:\n$errors';
      } else if (detail is String) {
        return detail;
      }
    }
  } catch (e) {
    print('422 에러 파싱 실패: $e');
  }
  
  return '입력값이 올바르지 않습니다. 모든 필드를 확인해주세요.';
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
