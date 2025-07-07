class MilkingRecord {
  final String id;
  final String cowId;
  final String recordDate;
  final double milkYield;
  final String milkingStartTime;
  final String milkingEndTime;
  final int milkingSession;
  final double conductivity;
  final int somaticCellCount;
  final bool bloodFlowDetected;
  final String colorValue;
  final double temperature;
  final double fatPercentage;
  final double proteinPercentage;
  final double airFlowValue;
  final int lactationNumber;
  final int ruminationTime;
  final String collectionCode;
  final int collectionCount;
  final String notes;

  MilkingRecord({
    required this.id,
    required this.cowId,
    required this.recordDate,
    required this.milkYield,
    required this.milkingStartTime,
    required this.milkingEndTime,
    required this.milkingSession,
    required this.conductivity,
    required this.somaticCellCount,
    required this.bloodFlowDetected,
    required this.colorValue,
    required this.temperature,
    required this.fatPercentage,
    required this.proteinPercentage,
    required this.airFlowValue,
    required this.lactationNumber,
    required this.ruminationTime,
    required this.collectionCode,
    required this.collectionCount,
    required this.notes,
  });

  // 문자열에서 숫자를 안전하게 추출하는 helper 함수
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // "41.0L", "12.5kg" 등의 단위가 포함된 문자열에서 숫자만 추출
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // 문자열에서 숫자만 추출
      String cleanValue = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  factory MilkingRecord.fromJson(Map<String, dynamic> json) {
    final safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // 🔧 핵심: record_data를 먼저 읽고
    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    // 🔧 key_values도 있으면 덮어씌우기
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    return MilkingRecord(
      id: safeJson['id'] ?? '',
      cowId: data['cow_id'] ?? safeJson['cow_id'] ?? '',
      recordDate: safeJson['record_date'] ?? '',
      milkYield: _parseDouble(data['milk_yield'] ?? 0),
      milkingSession: _parseInt(data['milking_session'] ?? 0),
      milkingStartTime: data['milking_start_time'] ?? '',
      milkingEndTime: data['milking_end_time'] ?? '',
      conductivity: _parseDouble(data['conductivity'] ?? 0),
      somaticCellCount: _parseInt(data['somatic_cell_count'] ?? 0),
      bloodFlowDetected: _parseBool(data['blood_flow_detected']),
      colorValue: data['color_value']?.toString() ?? '',
      temperature: _parseDouble(data['temperature'] ?? 0),
      fatPercentage: _parseDouble(data['fat_percentage'] ?? 0),
      proteinPercentage: _parseDouble(data['protein_percentage'] ?? 0),
      airFlowValue: _parseDouble(data['air_flow_value'] ?? 0),
      lactationNumber: _parseInt(data['lactation_number'] ?? 0),
      ruminationTime: _parseInt(data['rumination_time'] ?? 0),
      collectionCode: data['collection_code'] ?? '',
      collectionCount: _parseInt(data['collection_count'] ?? 0),
      notes: data['notes'] ?? safeJson['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'milk_yield': milkYield,
        'milking_start_time': milkingStartTime,
        'milking_end_time': milkingEndTime,
        'milking_session': milkingSession,
        'conductivity': conductivity,
        'somatic_cell_count': somaticCellCount,
        'blood_flow_detected': bloodFlowDetected,
        'color_value': colorValue,
        'temperature': temperature,
        'fat_percentage': fatPercentage,
        'protein_percentage': proteinPercentage,
        'air_flow_value': airFlowValue,
        'lactation_number': lactationNumber,
        'rumination_time': ruminationTime,
        'collection_code': collectionCode,
        'collection_count': collectionCount,
        'notes': notes,
      };
}
