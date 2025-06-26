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
    // record_data가 있으면 그걸 쓰고, 없으면 json 전체를 사용
    final data = json['record_data'] ?? json;

    String recordDateStr;
    final recordDateRaw = json['record_date'] ?? data['record_date'];
    if (recordDateRaw is int) {
      recordDateStr = DateTime.fromMillisecondsSinceEpoch(recordDateRaw * 1000)
          .toIso8601String()
          .split('T')[0];
    } else {
      recordDateStr = recordDateRaw?.toString() ?? '';
    }

    return HealthCheckRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: recordDateStr,
      checkTime: data['check_time'] ?? '',
      bodyTemperature: _parseDouble(data['body_temperature']),
      heartRate: _parseInt(data['heart_rate']),
      respiratoryRate: _parseInt(data['respiratory_rate']),
      bodyConditionScore: _parseDouble(data['body_condition_score']),
      udderCondition: data['udder_condition'] ?? '',
      hoofCondition: data['hoof_condition'] ?? '',
      coatCondition: data['coat_condition'] ?? '',
      eyeCondition: data['eye_condition'] ?? '',
      noseCondition: data['nose_condition'] ?? '',
      appetite: data['appetite'] ?? '',
      activityLevel: data['activity_level'] ?? '',
      abnormalSymptoms: (data['abnormal_symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      examiner: data['examiner'] ?? '',
      nextCheckDate: data['next_check_date'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
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
      };
}
