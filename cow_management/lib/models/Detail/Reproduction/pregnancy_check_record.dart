// 임신감정 모델

// pregnancy_check_record.dart

class PregnancyCheckRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String checkMethod;
  final String checkResult;
  final int pregnancyStage;
  final String fetusCondition;
  final String expectedCalvingDate;
  final String veterinarian;
  final double checkCost;
  final String nextCheckDate;
  final String additionalCare;
  final String notes;

  PregnancyCheckRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.checkMethod = '',
    this.checkResult = '',
    this.pregnancyStage = 0,
    this.fetusCondition = '',
    this.expectedCalvingDate = '',
    this.veterinarian = '',
    this.checkCost = 0.0,
    this.nextCheckDate = '',
    this.additionalCare = '',
    this.notes = '',
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(clean) ?? 0;
    }
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  factory PregnancyCheckRecord.fromJson(Map<String, dynamic> json) {
    final safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // ✅ record_data, key_values 병합
    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    // 🧷 cow_id, record_date 등도 병합
    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return PregnancyCheckRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      checkMethod: data['check_method']?.toString() ?? '',
      checkResult: data['check_result']?.toString() ?? '',
      pregnancyStage: _parseInt(data['pregnancy_stage']),
      fetusCondition: data['fetus_condition']?.toString() ?? '',
      expectedCalvingDate: data['expected_calving_date']?.toString() ?? '',
      veterinarian: data['veterinarian']?.toString() ?? '',
      checkCost: _parseDouble(data['check_cost']),
      nextCheckDate: data['next_check_date']?.toString() ?? '',
      additionalCare: data['additional_care']?.toString() ?? '',
      notes: data['notes']?.toString() ??
          safeJson['description']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '임신감정 기록',
        'description': notes.isNotEmpty ? notes : '임신감정 실시',
        'check_method': checkMethod,
        'check_result': checkResult,
        'pregnancy_stage': pregnancyStage,
        'fetus_condition': fetusCondition,
        'expected_calving_date': expectedCalvingDate,
        'veterinarian': veterinarian,
        'check_cost': checkCost,
        'next_check_date': nextCheckDate,
        'additional_care': additionalCare,
        'notes': notes,
      };
}
