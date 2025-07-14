class CalvingRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String? calvingStartTime;
  final String? calvingEndTime;
  final String? calvingDifficulty;
  final int? calfCount;
  final List<String>? calfGender;
  final List<double>? calfWeight;
  final List<String>? calfHealth;
  final bool? placentaExpelled;
  final String? placentaExpulsionTime;
  final List<String>? complications;
  final bool? assistanceRequired;
  final bool? veterinarianCalled;
  final String? damCondition;
  final String? lactationStart;
  final String? notes;

  CalvingRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.calvingStartTime,
    this.calvingEndTime,
    this.calvingDifficulty,
    this.calfCount,
    this.calfGender,
    this.calfWeight,
    this.calfHealth,
    this.placentaExpelled,
    this.placentaExpulsionTime,
    this.complications,
    this.assistanceRequired,
    this.veterinarianCalled,
    this.damCondition,
    this.lactationStart,
    this.notes,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String clean = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(clean);
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      String clean = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(clean);
    }
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return value.split(',').map((e) => e.trim()).toList();
    return null;
  }

  static List<double>? _parseDoubleList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => _parseDouble(e) ?? 0.0).toList();
    }
    return null;
  }

  factory CalvingRecord.fromJson(Map<String, dynamic> json) {
    final data = <String, dynamic>{};

    if (json['record_data'] != null && json['record_data'] is Map) {
      data.addAll(Map<String, dynamic>.from(json['record_data']));
    }
    if (json['key_values'] != null && json['key_values'] is Map) {
      data.addAll(Map<String, dynamic>.from(json['key_values']));
    }

    data['cow_id'] = json['cow_id'];
    data['record_date'] = json['record_date'];

    return CalvingRecord(
      id: json['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      calvingStartTime: data['calving_start_time'],
      calvingEndTime: data['calving_end_time'],
      calvingDifficulty: data['calving_difficulty'] ?? data['difficulty'],
      calfCount: _parseInt(data['calf_count']),
      calfGender: _parseStringList(data['calf_gender']),
      calfWeight: _parseDoubleList(data['calf_weight']),
      calfHealth: _parseStringList(data['calf_health']),
      placentaExpelled: data['placenta_expelled'],
      placentaExpulsionTime: data['placenta_expulsion_time'],
      complications: _parseStringList(data['complications']),
      assistanceRequired: data['assistance_required'],
      veterinarianCalled: data['veterinarian_called'],
      damCondition: data['dam_condition'],
      lactationStart: data['lactation_start'],
      notes: data['notes'] ?? json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '분만 기록',
        'description': notes ?? '분만 기록 작성',
        if (calvingStartTime != null) 'calving_start_time': calvingStartTime,
        if (calvingEndTime != null) 'calving_end_time': calvingEndTime,
        if (calvingDifficulty != null) 'calving_difficulty': calvingDifficulty,
        if (calfCount != null) 'calf_count': calfCount,
        if (calfGender != null) 'calf_gender': calfGender,
        if (calfWeight != null) 'calf_weight': calfWeight,
        if (calfHealth != null) 'calf_health': calfHealth,
        if (placentaExpelled != null) 'placenta_expelled': placentaExpelled,
        if (placentaExpulsionTime != null)
          'placenta_expulsion_time': placentaExpulsionTime,
        if (complications != null) 'complications': complications,
        if (assistanceRequired != null)
          'assistance_required': assistanceRequired,
        if (veterinarianCalled != null)
          'veterinarian_called': veterinarianCalled,
        if (damCondition != null) 'dam_condition': damCondition,
        if (lactationStart != null) 'lactation_start': lactationStart,
        if (notes != null) 'notes': notes,
      };

  Map<String, dynamic> toUpdateJson() => {
        'record_date': recordDate,
        'record_data': {
          if (calvingStartTime != null) 'calving_start_time': calvingStartTime,
          if (calvingEndTime != null) 'calving_end_time': calvingEndTime,
          if (calvingDifficulty != null)
            'calving_difficulty': calvingDifficulty,
          if (calfCount != null) 'calf_count': calfCount,
          if (calfGender != null) 'calf_gender': calfGender,
          if (calfWeight != null) 'calf_weight': calfWeight,
          if (calfHealth != null) 'calf_health': calfHealth,
          if (placentaExpelled != null) 'placenta_expelled': placentaExpelled,
          if (placentaExpulsionTime != null)
            'placenta_expulsion_time': placentaExpulsionTime,
          if (complications != null) 'complications': complications,
          if (assistanceRequired != null)
            'assistance_required': assistanceRequired,
          if (veterinarianCalled != null)
            'veterinarian_called': veterinarianCalled,
          if (damCondition != null) 'dam_condition': damCondition,
          if (lactationStart != null) 'lactation_start': lactationStart,
          if (notes != null) 'notes': notes,
        },
      };
}
