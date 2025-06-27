// health_check_record.dart

class HealthCheckRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String checkTime;
  final double bodyTemperature;
  final int heartRate;
  final int respiratoryRate;
  final double bodyConditionScore;
  final String udderCondition;
  final String hoofCondition;
  final String coatCondition;
  final String eyeCondition;
  final String noseCondition;
  final String appetite;
  final String activityLevel;
  final List<String> abnormalSymptoms;
  final String examiner;
  final String nextCheckDate;
  final String notes;

  HealthCheckRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.checkTime = '',
    this.bodyTemperature = 0.0,
    this.heartRate = 0,
    this.respiratoryRate = 0,
    this.bodyConditionScore = 0.0,
    this.udderCondition = '',
    this.hoofCondition = '',
    this.coatCondition = '',
    this.eyeCondition = '',
    this.noseCondition = '',
    this.appetite = '',
    this.activityLevel = '',
    this.abnormalSymptoms = const [],
    this.examiner = '',
    this.nextCheckDate = '',
    this.notes = '',
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  factory HealthCheckRecord.fromJson(Map<String, dynamic> json) {
    // 안전한 타입 캐스팅
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    
    // 데이터 소스 우선순위: key_values > record_data > 기본 json
    Map<String, dynamic> data = {};
    
    // 기본 json 데이터 추가
    data.addAll(safeJson);
    
    // record_data가 있으면 추가
    if (safeJson['record_data'] != null) {
      final recordData = Map<String, dynamic>.from(safeJson['record_data']);
      data.addAll(recordData);
    }
    
    // key_values가 있으면 우선적으로 사용 (서버 응답 형태)
    if (safeJson['key_values'] != null) {
      final keyValues = Map<String, dynamic>.from(safeJson['key_values']);
      
      // key_values에서 필드 매핑
      if (keyValues.containsKey('temperature')) {
        data['body_temperature'] = keyValues['temperature'];
      }
      if (keyValues.containsKey('bcs')) {
        data['body_condition_score'] = keyValues['bcs'];
      }
    }

    String recordDateStr;
    final recordDateRaw = safeJson['record_date'] ?? data['record_date'];
    if (recordDateRaw is int) {
      recordDateStr = DateTime.fromMillisecondsSinceEpoch(recordDateRaw * 1000)
          .toIso8601String()
          .split('T')[0];
    } else {
      recordDateStr = recordDateRaw?.toString() ?? '';
    }

    return HealthCheckRecord(
      id: safeJson['id']?.toString(),
      cowId: safeJson['cow_id']?.toString() ?? data['cow_id']?.toString() ?? '',
      recordDate: recordDateStr,
      checkTime: data['check_time']?.toString() ?? '',
      bodyTemperature: _parseDouble(data['body_temperature']),
      heartRate: _parseInt(data['heart_rate']),
      respiratoryRate: _parseInt(data['respiratory_rate']),
      bodyConditionScore: _parseDouble(data['body_condition_score']),
      udderCondition: data['udder_condition']?.toString() ?? '',
      hoofCondition: data['hoof_condition']?.toString() ?? '',
      coatCondition: data['coat_condition']?.toString() ?? '',
      eyeCondition: data['eye_condition']?.toString() ?? '',
      noseCondition: data['nose_condition']?.toString() ?? '',
      appetite: data['appetite']?.toString() ?? '',
      activityLevel: data['activity_level']?.toString() ?? '',
      abnormalSymptoms: (data['abnormal_symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      examiner: data['examiner']?.toString() ?? '',
      nextCheckDate: data['next_check_date']?.toString() ?? '',
      notes: data['notes']?.toString() ?? safeJson['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '건강검진 기록',
        'description': notes.isNotEmpty ? notes : '건강검진 실시',
        'record_data': {
          'check_time': checkTime,
          'body_temperature': bodyTemperature,
          'heart_rate': heartRate,
          'respiratory_rate': respiratoryRate,
          'body_condition_score': bodyConditionScore,
          'udder_condition': udderCondition,
          'hoof_condition': hoofCondition,
          'coat_condition': coatCondition,
          'eye_condition': eyeCondition,
          'nose_condition': noseCondition,
          'appetite': appetite,
          'activity_level': activityLevel,
          'abnormal_symptoms': abnormalSymptoms,
          'examiner': examiner,
          'next_check_date': nextCheckDate,
          'notes': notes,
        },
      };
}
