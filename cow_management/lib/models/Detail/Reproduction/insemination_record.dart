class InseminationRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? inseminationTime;
  final String? bullId;
  final String? bullBreed;
  final String? semenBatch;
  final String? semenQuality;
  final String? inseminationMethod;
  final String? technicianName;
  final String? cervixCondition;
  final double? successProbability;
  final String? expectedCalvingDate;
  final String? pregnancyCheckScheduled;
  final double? cost;
  final String? notes;
  final String? inseminationResult;

  InseminationRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.inseminationTime,
    this.bullId,
    this.bullBreed,
    this.semenBatch,
    this.semenQuality,
    this.inseminationMethod,
    this.technicianName,
    this.cervixCondition,
    this.successProbability,
    this.expectedCalvingDate,
    this.pregnancyCheckScheduled,
    this.cost,
    this.notes,
    this.inseminationResult,
  });

  InseminationRecord copyWith({
    String? cowId,
    String? recordDate,
    String? inseminationTime,
    String? bullId,
    String? inseminationResult,
    String? bullBreed,
    String? semenBatch,
    String? semenQuality,
    String? inseminationMethod,
    String? technicianName,
    String? cervixCondition,
    double? successProbability,
    String? expectedCalvingDate,
    String? pregnancyCheckScheduled,
    double? cost,
    String? notes,
  }) {
    return InseminationRecord(
      cowId: cowId ?? this.cowId,
      recordDate: recordDate ?? this.recordDate,
      inseminationTime: inseminationTime ?? this.inseminationTime,
      bullId: bullId ?? this.bullId,
      bullBreed: bullBreed ?? this.bullBreed,
      semenBatch: semenBatch ?? this.semenBatch,
      semenQuality: semenQuality ?? this.semenQuality,
      inseminationMethod: inseminationMethod ?? this.inseminationMethod,
      technicianName: technicianName ?? this.technicianName,
      cervixCondition: cervixCondition ?? this.cervixCondition,
      successProbability: successProbability ?? this.successProbability,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      pregnancyCheckScheduled:
          pregnancyCheckScheduled ?? this.pregnancyCheckScheduled,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory InseminationRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // ✅ record_data, key_values 병합
    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    // ✅ cow_id, record_date 포함
    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return InseminationRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      inseminationTime: data['insemination_time'],
      bullId: data['bull_id'],
      bullBreed: data['bull_breed'],
      semenBatch: data['semen_batch'],
      semenQuality: data['semen_quality'],
      inseminationMethod: data['insemination_method'],
      technicianName: data['technician_name'],
      cervixCondition: data['cervix_condition'],
      successProbability: _parseDouble(data['success_probability']),
      pregnancyCheckScheduled: data['pregnancy_check_scheduled'],
      cost: _parseDouble(data['cost']),
      notes: data['notes'] ?? safeJson['description'],
      inseminationResult: data['insemination_result'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'insemination_time': inseminationTime,
        'bull_id': bullId,
        'bull_breed': bullBreed,
        'semen_batch': semenBatch,
        'semen_quality': semenQuality,
        'insemination_method': inseminationMethod,
        'technician_name': technicianName,
        'cervix_condition': cervixCondition,
        'success_probability': successProbability,
        'pregnancy_check_scheduled': pregnancyCheckScheduled,
        'cost': cost,
        'notes': notes,
        'insemination_result': inseminationResult,
      };
}
