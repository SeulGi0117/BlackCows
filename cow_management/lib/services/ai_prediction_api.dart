import 'package:dio/dio.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// 유방염 예측 결과 모델
class MastitisPredictionResult {
  final int? predictionClass;           // 0: 정상, 1: 주의, 2: 염증 가능성
  final String? predictionClassLabel;   // "정상", "주의", "염증 가능성"
  final double? confidence;             // 예측 신뢰도 (%)
  final String? predictionMethod;       // 예측 방법 (체세포수 기반일 때)
  final Map<String, dynamic>? inputFeatures; // 입력 특성값들 (생체정보 기반일 때)
  final String? errorMessage;
  final bool isSuccess;

  MastitisPredictionResult({
    this.predictionClass,
    this.predictionClassLabel,
    this.confidence,
    this.predictionMethod,
    this.inputFeatures,
    this.errorMessage,
    required this.isSuccess,
  });
}

// 토큰 가져오기 헬퍼 함수
Future<String?> _getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
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
    // 소 목록 불러오기와 동일한 방식으로 토큰 처리
    final dio = Dio();
    final apiUrl = ApiConfig.baseUrl;
    final token = await _getAccessToken();
    
    if (token == null) {
      return MilkYieldPredictionResult(
        isSuccess: false,
        errorMessage: '로그인이 필요합니다.',
      );
    }

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

    final response = await dio.post(
      '$apiUrl/ai/milk-yield/predict', 
      data: {
        'milking_frequency': milking_frequency,
        'conductivity': conductivity,
        'temperature': temperature,
        'fat_percentage': fat_percentage,
        'protein_percentage': protein_percentage,
        'concentrate_intake': concentrate_intake,
        'milking_month': milking_month,
        'milking_day_of_week': milking_day_of_week,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    
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
      print('❌ 요청 헤더: ${e.requestOptions.headers}');
      print('❌ 상태 코드: ${e.response?.statusCode}');
      
      // HTTP 상태 코드별 에러 메시지
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      switch (statusCode) {
        case 400:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: '잘못된 요청입니다. 입력값을 확인해주세요.',
          );
        case 401:
        case 403:
          return MilkYieldPredictionResult(
            isSuccess: false,
            errorMessage: '인증이 만료되었습니다. 다시 로그인해주세요.',
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
  
  if (fat_percentage <= 0 || fat_percentage > 10) {
    return '유지방 비율은 0% ~ 10% 범위여야 합니다.';
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

// 유방염 예측 (체세포수 없음 모드)
Future<MastitisPredictionResult> mastitisPrediction({
  required double milk_yield,
  required double conductivity,
  required double fat_percentage,
  required double protein_percentage,
  required int lactation_number,
  String? cow_id,
  String? prediction_date,
  String? notes,
}) async {
  try {
    // 소 목록 불러오기와 동일한 방식으로 토큰 처리
    final dio = Dio();
    final apiUrl = ApiConfig.baseUrl;
    final token = await _getAccessToken();
    
    if (token == null) {
      return MastitisPredictionResult(
        isSuccess: false,
        errorMessage: '로그인이 필요합니다.',
      );
    }

    // 입력값 검증
    final validationError = _validateMastitisInputs(
      milk_yield: milk_yield,
      conductivity: conductivity,
      fat_percentage: fat_percentage,
      protein_percentage: protein_percentage,
      lactation_number: lactation_number,
    );
    
    if (validationError != null) {
      return MastitisPredictionResult(
        isSuccess: false,
        errorMessage: validationError,
      );
    }

    final requestData = {
      'milk_yield': milk_yield,
      'conductivity': conductivity,
      'fat_percentage': fat_percentage,
      'protein_percentage': protein_percentage,
      'lactation_number': lactation_number,
      if (cow_id != null) 'cow_id': cow_id,
      if (prediction_date != null) 'prediction_date': prediction_date,
      if (notes != null) 'notes': notes,
    };

    print('🔍 유방염 예측 요청 데이터: $requestData');

    final response = await dio.post(
      '$apiUrl/ai/mastitis/predict', 
      data: requestData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    return MastitisPredictionResult(
      predictionClass: response.data['prediction_class'] as int?,
      predictionClassLabel: response.data['prediction_class_label'] as String?,
      confidence: (response.data['confidence'] as num?)?.toDouble(),
      inputFeatures: response.data['input_features'] as Map<String, dynamic>?,
      isSuccess: true,
    );
  } catch (e) {
    print('❌ 유방염 예측 실패: $e');
    
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      switch (statusCode) {
        case 400:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '잘못된 요청입니다. 입력값을 확인해주세요.',
          );
        case 401:
        case 403:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '인증이 만료되었습니다. 다시 로그인해주세요.',
          );
        case 422:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: _parse422Error(errorData),
          );
        case 500:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          );
        case 503:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: 'AI 서비스가 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
          );
        default:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '네트워크 오류가 발생했습니다. 연결을 확인해주세요.',
          );
      }
    }
    
    return MastitisPredictionResult(
      isSuccess: false,
      errorMessage: '알 수 없는 오류가 발생했습니다.',
    );
  }
}

// 체세포수 기반 유방염 예측 (체세포수 있음 모드)
Future<MastitisPredictionResult> sccMastitisPrediction({
  required int somatic_cell_count,
  String? cow_id,
  String? prediction_date,
  String? notes,
}) async {
  try {
    // 소 목록 불러오기와 동일한 방식으로 토큰 처리
    final dio = Dio();
    final apiUrl = ApiConfig.baseUrl;
    final token = await _getAccessToken();
    
    if (token == null) {
      return MastitisPredictionResult(
        isSuccess: false,
        errorMessage: '로그인이 필요합니다.',
      );
    }

    // 입력값 검증
    final validationError = _validateSCCInputs(
      somatic_cell_count: somatic_cell_count,
    );
    
    if (validationError != null) {
      return MastitisPredictionResult(
        isSuccess: false,
        errorMessage: validationError,
      );
    }

    final requestData = {
      'somatic_cell_count': somatic_cell_count,
      if (cow_id != null) 'cow_id': cow_id,
      if (prediction_date != null) 'prediction_date': prediction_date,
      if (notes != null) 'notes': notes,
    };

    print('🔍 체세포수 기반 유방염 예측 요청 데이터: $requestData');

    final response = await dio.post(
      '$apiUrl/ai/scc-mastitis/predict', 
      data: requestData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    return MastitisPredictionResult(
      predictionClass: response.data['prediction_class'] as int?,
      predictionClassLabel: response.data['prediction_class_label'] as String?,
      confidence: (response.data['confidence'] as num?)?.toDouble(),
      predictionMethod: response.data['prediction_method'] as String?,
      isSuccess: true,
    );
  } catch (e) {
    print('❌ 체세포수 기반 유방염 예측 실패: $e');
    
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      switch (statusCode) {
        case 400:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '잘못된 요청입니다. 입력값을 확인해주세요.',
          );
        case 401:
        case 403:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '인증이 만료되었습니다. 다시 로그인해주세요.',
          );
        case 422:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: _parse422Error(errorData),
          );
        case 500:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          );
        case 503:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: 'AI 서비스가 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
          );
        default:
          return MastitisPredictionResult(
            isSuccess: false,
            errorMessage: '네트워크 오류가 발생했습니다. 연결을 확인해주세요.',
          );
      }
    }
    
    return MastitisPredictionResult(
      isSuccess: false,
      errorMessage: '알 수 없는 오류가 발생했습니다.',
    );
  }
}

// 유방염 예측 입력값 검증
String? _validateMastitisInputs({
  required double milk_yield,
  required double conductivity,
  required double fat_percentage,
  required double protein_percentage,
  required int lactation_number,
}) {
  if (milk_yield <= 0) {
    return '착유량은 0보다 큰 값이어야 합니다.';
  }
  if (milk_yield > 100) {
    return '착유량은 100L 이하여야 합니다.';
  }
  
  if (conductivity <= 0) {
    return '전도율은 0보다 큰 값이어야 합니다.';
  }
  if (conductivity > 20) {
    return '전도율은 20 mS/cm 이하여야 합니다.';
  }
  
  if (fat_percentage <= 0 || fat_percentage > 10) {
    return '유지방 비율은 0% ~ 10% 범위여야 합니다.';
  }
  
  if (protein_percentage <= 0 || protein_percentage > 10) {
    return '유단백 비율은 0% ~ 10% 범위여야 합니다.';
  }
  
  if (lactation_number <= 0) {
    return '산차수는 1 이상이어야 합니다.';
  }
  if (lactation_number > 20) {
    return '산차수는 20 이하여야 합니다.';
  }
  
  return null;
}

// 체세포수 입력값 검증
String? _validateSCCInputs({
  required int somatic_cell_count,
}) {
  if (somatic_cell_count <= 0) {
    return '체세포수는 0보다 큰 값이어야 합니다.';
  }
  if (somatic_cell_count > 10000) {
    return '체세포수는 10,000개/ml 이하여야 합니다.';
  }
  
  return null;
}
