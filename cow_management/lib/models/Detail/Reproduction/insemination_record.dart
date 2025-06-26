class InseminationRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? inseminationTime;
  final String? bullInfo;
  final String? semenQuality;
  final String? inseminationMethod;
  final String? veterinarian;
  final double? cost;
  final String? expectedCalvingDate;
  final String? inseminationResult;
  final String? notes;

  InseminationRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.inseminationTime,
    this.bullInfo,
    this.semenQuality,
    this.inseminationMethod,
    this.veterinarian,
    this.cost,
    this.expectedCalvingDate,
    this.inseminationResult,
    this.notes,
  });

  InseminationRecord copyWith({
    String? cowId,
    String? recordDate,
    String? inseminationTime,
    String? bullInfo,
    String? semenQuality,
    String? inseminationMethod,
    String? veterinarian,
    double? cost,
    String? expectedCalvingDate,
    String? inseminationResult,
    String? notes,
  }) {
    return InseminationRecord(
      cowId: cowId ?? this.cowId,
      recordDate: recordDate ?? this.recordDate,
      inseminationTime: inseminationTime ?? this.inseminationTime,
      bullInfo: bullInfo ?? this.bullInfo,
      semenQuality: semenQuality ?? this.semenQuality,
      inseminationMethod: inseminationMethod ?? this.inseminationMethod,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      inseminationResult: inseminationResult ?? this.inseminationResult,
      notes: notes ?? this.notes,
    );
  }

  factory InseminationRecord.fromJson(Map<String, dynamic> json) {
    return InseminationRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      inseminationTime: json['insemination_time'],
      bullInfo: json['bull_info'],
      semenQuality: json['semen_quality'],
      inseminationMethod: json['insemination_method'],
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      expectedCalvingDate: json['expected_calving_date'],
      inseminationResult: json['insemination_result'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'insemination_time': inseminationTime,
        'bull_info': bullInfo,
        'semen_quality': semenQuality,
        'insemination_method': inseminationMethod,
        'veterinarian': veterinarian,
        'cost': cost,
        'expected_calving_date': expectedCalvingDate,
        'insemination_result': inseminationResult,
        'notes': notes,
      };
} 