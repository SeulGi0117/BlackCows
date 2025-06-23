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

  factory MilkingRecord.fromJson(Map<String, dynamic> json) {
    final data = json['key_values'] ?? {};
    return MilkingRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      milkYield: (data['milk_yield'] ?? 0).toDouble(),
      milkingStartTime: data['milking_start_time'] ?? '',
      milkingEndTime: data['milking_end_time'] ?? '',
      milkingSession: data['milking_session'] ?? 0,
      conductivity: (data['conductivity'] ?? 0).toDouble(),
      somaticCellCount: data['somatic_cell_count'] ?? 0,
      bloodFlowDetected: data['blood_flow_detected'] ?? false,
      colorValue: data['color_value'] ?? '',
      temperature: (data['temperature'] ?? 0).toDouble(),
      fatPercentage: (data['fat_percentage'] ?? 0).toDouble(),
      proteinPercentage: (data['protein_percentage'] ?? 0).toDouble(),
      airFlowValue: (data['air_flow_value'] ?? 0).toDouble(),
      lactationNumber: data['lactation_number'] ?? 0,
      ruminationTime: data['rumination_time'] ?? 0,
      collectionCode: data['collection_code'] ?? '',
      collectionCount: data['collection_count'] ?? 0,
      notes: data['notes'] ?? '',
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
