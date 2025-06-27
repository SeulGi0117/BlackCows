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
  final String? pregnancyCheckScheduled;
  final double? cost;
  final String? notes;

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
    this.pregnancyCheckScheduled,
    this.cost,
    this.notes,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory InseminationRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    final Map<String, dynamic> data = {};

    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return InseminationRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      inseminationTime: data['insemination_time'],
      bullId: data['bull_id'],
      bullBreed: data['bull_breed'] ?? data['bull'], // ✅ 보완
      semenBatch: data['semen_batch'],
      semenQuality: data['semen_quality'] ?? data['quality'], // ✅ 보완
      inseminationMethod: data['insemination_method'] ?? data['method'], // ✅ 보완
      technicianName: data['technician_name'] ?? data['technician'], // ✅ 보완
      cervixCondition: data['cervix_condition'],
      successProbability: _parseDouble(data['success_probability']),
      pregnancyCheckScheduled: data['pregnancy_check_scheduled'],
      cost: _parseDouble(data['cost']),
      notes: data['notes'] ?? safeJson['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '인공수정 기록',
        'description': notes ?? '인공수정 실시',
        if (inseminationTime != null) 'insemination_time': inseminationTime,
        if (bullId != null) 'bull_id': bullId,
        if (bullBreed != null) 'bull_breed': bullBreed,
        if (semenBatch != null) 'semen_batch': semenBatch,
        if (semenQuality != null) 'semen_quality': semenQuality,
        if (inseminationMethod != null)
          'insemination_method': inseminationMethod,
        if (technicianName != null) 'technician_name': technicianName,
        if (cervixCondition != null) 'cervix_condition': cervixCondition,
        if (successProbability != null)
          'success_probability': successProbability,
        if (pregnancyCheckScheduled != null)
          'pregnancy_check_scheduled': pregnancyCheckScheduled,
        if (cost != null) 'cost': cost,
        if (notes != null) 'notes': notes,
      };
}
