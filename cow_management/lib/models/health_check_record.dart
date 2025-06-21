class HealthCheckRecord {
  final String id;
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
    required this.id,
    required this.cowId,
    required this.recordDate,
    required this.checkTime,
    required this.bodyTemperature,
    required this.heartRate,
    required this.respiratoryRate,
    required this.bodyConditionScore,
    required this.udderCondition,
    required this.hoofCondition,
    required this.coatCondition,
    required this.eyeCondition,
    required this.noseCondition,
    required this.appetite,
    required this.activityLevel,
    required this.abnormalSymptoms,
    required this.examiner,
    required this.nextCheckDate,
    required this.notes,
  });

  factory HealthCheckRecord.fromJson(Map<String, dynamic> json) {
    return HealthCheckRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      checkTime: json['check_time'],
      bodyTemperature: json['body_temperature'].toDouble(),
      heartRate: json['heart_rate'],
      respiratoryRate: json['respiratory_rate'],
      bodyConditionScore: json['body_condition_score'].toDouble(),
      udderCondition: json['udder_condition'],
      hoofCondition: json['hoof_condition'],
      coatCondition: json['coat_condition'],
      eyeCondition: json['eye_condition'],
      noseCondition: json['nose_condition'],
      appetite: json['appetite'],
      activityLevel: json['activity_level'],
      abnormalSymptoms: List<String>.from(json['abnormal_symptoms']),
      examiner: json['examiner'],
      nextCheckDate: json['next_check_date'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}
