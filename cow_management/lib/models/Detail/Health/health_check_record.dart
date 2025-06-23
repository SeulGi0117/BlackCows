class HealthCheckRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String? checkTime;
  final double? bodyTemperature;
  final int? heartRate;
  final int? respiratoryRate;
  final double? bodyConditionScore;
  final String? udderCondition;
  final String? hoofCondition;
  final String? coatCondition;
  final String? eyeCondition;
  final String? noseCondition;
  final String? appetite;
  final String? activityLevel;
  final List<String>? abnormalSymptoms;
  final String? examiner;
  final String? nextCheckDate;
  final String? notes;

  HealthCheckRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.checkTime,
    this.bodyTemperature,
    this.heartRate,
    this.respiratoryRate,
    this.bodyConditionScore,
    this.udderCondition,
    this.hoofCondition,
    this.coatCondition,
    this.eyeCondition,
    this.noseCondition,
    this.appetite,
    this.activityLevel,
    this.abnormalSymptoms,
    this.examiner,
    this.nextCheckDate,
    this.notes,
  });

  factory HealthCheckRecord.fromJson(Map<String, dynamic> json) {
    return HealthCheckRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      checkTime: json['check_time'],
      bodyTemperature: (json['body_temperature'] as num?)?.toDouble(),
      heartRate: json['heart_rate'],
      respiratoryRate: json['respiratory_rate'],
      bodyConditionScore: (json['body_condition_score'] as num?)?.toDouble(),
      udderCondition: json['udder_condition'],
      hoofCondition: json['hoof_condition'],
      coatCondition: json['coat_condition'],
      eyeCondition: json['eye_condition'],
      noseCondition: json['nose_condition'],
      appetite: json['appetite'],
      activityLevel: json['activity_level'],
      abnormalSymptoms: (json['abnormal_symptoms'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      examiner: json['examiner'],
      nextCheckDate: json['next_check_date'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'cow_id': cowId,
      'record_date': recordDate,
    };
    if (checkTime != null) data['check_time'] = checkTime;
    if (bodyTemperature != null) data['body_temperature'] = bodyTemperature;
    if (heartRate != null) data['heart_rate'] = heartRate;
    if (respiratoryRate != null) data['respiratory_rate'] = respiratoryRate;
    if (bodyConditionScore != null) {
      data['body_condition_score'] = bodyConditionScore;
    }
    if (udderCondition != null) data['udder_condition'] = udderCondition;
    if (hoofCondition != null) data['hoof_condition'] = hoofCondition;
    if (coatCondition != null) data['coat_condition'] = coatCondition;
    if (eyeCondition != null) data['eye_condition'] = eyeCondition;
    if (noseCondition != null) data['nose_condition'] = noseCondition;
    if (appetite != null) data['appetite'] = appetite;
    if (activityLevel != null) data['activity_level'] = activityLevel;
    if (abnormalSymptoms != null) data['abnormal_symptoms'] = abnormalSymptoms;
    if (examiner != null) data['examiner'] = examiner;
    if (nextCheckDate != null) data['next_check_date'] = nextCheckDate;
    if (notes != null) data['notes'] = notes;
    return data;
  }

  Map<String, dynamic> toRecordDataJson() {
    final fullJson = toJson();
    fullJson.remove('cow_id');
    fullJson.remove('record_date');
    return fullJson;
  }
}
