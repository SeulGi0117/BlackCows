class PregnancyCheckRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? checkMethod;
  final String? checkResult;
  final String? expectedCalvingDate;
  final int? pregnancyDays;
  final String? veterinarian;
  final double? cost;
  final String? notes;

  PregnancyCheckRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.checkMethod,
    this.checkResult,
    this.expectedCalvingDate,
    this.pregnancyDays,
    this.veterinarian,
    this.cost,
    this.notes,
  });

  PregnancyCheckRecord copyWith({
    String? cowId,
    String? recordDate,
    String? checkMethod,
    String? checkResult,
    String? expectedCalvingDate,
    int? pregnancyDays,
    String? veterinarian,
    double? cost,
    String? notes,
  }) {
    return PregnancyCheckRecord(
      cowId: cowId ?? this.cowId,
      recordDate: recordDate ?? this.recordDate,
      checkMethod: checkMethod ?? this.checkMethod,
      checkResult: checkResult ?? this.checkResult,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      pregnancyDays: pregnancyDays ?? this.pregnancyDays,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
    );
  }

  factory PregnancyCheckRecord.fromJson(Map<String, dynamic> json) {
    return PregnancyCheckRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      checkMethod: json['check_method'],
      checkResult: json['check_result'],
      expectedCalvingDate: json['expected_calving_date'],
      pregnancyDays: json['pregnancy_days']?.toInt(),
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'check_method': checkMethod,
        'check_result': checkResult,
        'expected_calving_date': expectedCalvingDate,
        'pregnancy_days': pregnancyDays,
        'veterinarian': veterinarian,
        'cost': cost,
        'notes': notes,
      };
} 