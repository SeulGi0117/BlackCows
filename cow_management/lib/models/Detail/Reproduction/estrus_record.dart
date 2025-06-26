class EstrusRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? estrusStartTime;
  final String? estrusIntensity;
  final int? estrusDuration;
  final List<String>? behaviorSigns;
  final List<String>? visualSigns;
  final String? detectedBy;
  final String? detectionMethod;
  final String? nextExpectedEstrus;
  final bool? breedingPlanned;
  final String? notes;

  EstrusRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.estrusStartTime,
    this.estrusIntensity,
    this.estrusDuration,
    this.behaviorSigns,
    this.visualSigns,
    this.detectedBy,
    this.detectionMethod,
    this.nextExpectedEstrus,
    this.breedingPlanned,
    this.notes,
  });

  EstrusRecord copyWith({
    String? cowId,
    String? recordDate,
    String? estrusStartTime,
    String? estrusIntensity,
    int? estrusDuration,
    List<String>? behaviorSigns,
    List<String>? visualSigns,
    String? detectedBy,
    String? detectionMethod,
    String? nextExpectedEstrus,
    bool? breedingPlanned,
    String? notes,
  }) {
    return EstrusRecord(
      cowId: cowId ?? this.cowId,
      recordDate: recordDate ?? this.recordDate,
      estrusStartTime: estrusStartTime ?? this.estrusStartTime,
      estrusIntensity: estrusIntensity ?? this.estrusIntensity,
      estrusDuration: estrusDuration ?? this.estrusDuration,
      behaviorSigns: behaviorSigns ?? this.behaviorSigns,
      visualSigns: visualSigns ?? this.visualSigns,
      detectedBy: detectedBy ?? this.detectedBy,
      detectionMethod: detectionMethod ?? this.detectionMethod,
      nextExpectedEstrus: nextExpectedEstrus ?? this.nextExpectedEstrus,
      breedingPlanned: breedingPlanned ?? this.breedingPlanned,
      notes: notes ?? this.notes,
    );
  }

  factory EstrusRecord.fromJson(Map<String, dynamic> json) {
    return EstrusRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      estrusStartTime: json['estrus_start_time'],
      estrusIntensity: json['estrus_intensity'],
      estrusDuration: json['estrus_duration'] is int
          ? json['estrus_duration']
          : int.tryParse(json['estrus_duration']?.toString() ?? ''),
      behaviorSigns: (json['behavior_signs'] is List)
          ? (json['behavior_signs'] as List).map((e) => e.toString()).toList()
          : [],
      visualSigns: (json['visual_signs'] is List)
          ? (json['visual_signs'] as List).map((e) => e.toString()).toList()
          : [],
      detectedBy: json['detected_by'],
      detectionMethod: json['detection_method'],
      nextExpectedEstrus: json['next_expected_estrus'],
      breedingPlanned: json['breeding_planned'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'estrus_start_time': estrusStartTime,
        'estrus_intensity': estrusIntensity,
        'estrus_duration': estrusDuration,
        'behavior_signs': behaviorSigns,
        'visual_signs': visualSigns,
        'detected_by': detectedBy,
        'detection_method': detectionMethod,
        'next_expected_estrus': nextExpectedEstrus,
        'breeding_planned': breedingPlanned,
        'notes': notes,
      };
}
