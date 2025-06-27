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

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleanValue);
    }
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return value.split(',').map((e) => e.trim()).toList();
    }
    return null;
  }

  factory EstrusRecord.fromJson(Map<String, dynamic> json) {
    // 안전한 타입 캐스팅
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    
    // 데이터 소스 우선순위: key_values > record_data > 기본 json
    Map<String, dynamic> data = {};
    
    // 기본 json 데이터 추가
    data.addAll(safeJson);
    
    // record_data가 있으면 추가
    if (safeJson['record_data'] != null) {
      final recordData = Map<String, dynamic>.from(safeJson['record_data']);
      data.addAll(recordData);
    }
    
    // key_values가 있으면 우선적으로 사용 (서버 응답 형태)
    if (safeJson['key_values'] != null) {
      final keyValues = Map<String, dynamic>.from(safeJson['key_values']);
      
      // key_values에서 필드 매핑
      if (keyValues.containsKey('estrus_intensity')) {
        data['estrus_intensity'] = keyValues['estrus_intensity'];
      }
      if (keyValues.containsKey('estrus_duration')) {
        data['estrus_duration'] = keyValues['estrus_duration'];
      }
      if (keyValues.containsKey('detected_by')) {
        data['detected_by'] = keyValues['detected_by'];
      }
    }

    String recordDateStr;
    final recordDateRaw = safeJson['record_date'] ?? data['record_date'];
    if (recordDateRaw is int) {
      recordDateStr = DateTime.fromMillisecondsSinceEpoch(recordDateRaw * 1000)
          .toIso8601String()
          .split('T')[0];
    } else {
      recordDateStr = recordDateRaw?.toString() ?? '';
    }

    return EstrusRecord(
      id: safeJson['id']?.toString(),
      cowId: safeJson['cow_id']?.toString() ?? data['cow_id']?.toString() ?? '',
      recordDate: recordDateStr,
      estrusStartTime: data['estrus_start_time']?.toString(),
      estrusIntensity: data['estrus_intensity']?.toString(),
      estrusDuration: _parseInt(data['estrus_duration']),
      behaviorSigns: _parseStringList(data['behavior_signs']),
      visualSigns: _parseStringList(data['visual_signs']),
      detectedBy: data['detected_by']?.toString(),
      detectionMethod: data['detection_method']?.toString(),
      nextExpectedEstrus: data['next_expected_estrus']?.toString(),
      breedingPlanned: data['breeding_planned'] as bool?,
      notes: data['notes']?.toString() ?? safeJson['description']?.toString(),
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
