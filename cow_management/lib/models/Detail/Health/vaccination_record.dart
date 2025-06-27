class VaccinationRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? vaccinationTime;
  final String? vaccineName;
  final String? vaccineType;
  final String? vaccineBatch;
  final double? dosage;
  final String? injectionSite;
  final String? injectionMethod;
  final String? administrator;
  final String? vaccineManufacturer;
  final String? expiryDate;
  final bool? adverseReaction;
  final String? reactionDetails;
  final String? nextVaccinationDue;
  final int? cost;
  final String? notes;

  VaccinationRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.vaccinationTime,
    this.vaccineName,
    this.vaccineType,
    this.vaccineBatch,
    this.dosage,
    this.injectionSite,
    this.injectionMethod,
    this.administrator,
    this.vaccineManufacturer,
    this.expiryDate,
    this.adverseReaction,
    this.reactionDetails,
    this.nextVaccinationDue,
    this.cost,
    this.notes,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
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

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
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
      if (keyValues.containsKey('vaccine')) {
        data['vaccine_name'] = keyValues['vaccine'];
      }
      if (keyValues.containsKey('dosage')) {
        data['dosage'] = keyValues['dosage'];
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

    return VaccinationRecord(
      id: safeJson['id']?.toString(),
      cowId: safeJson['cow_id']?.toString() ?? data['cow_id']?.toString() ?? '',
      recordDate: recordDateStr,
      vaccinationTime: data['vaccination_time']?.toString(),
      vaccineName: data['vaccine_name']?.toString(),
      vaccineType: data['vaccine_type']?.toString(),
      vaccineBatch: data['vaccine_batch']?.toString(),
      dosage: _parseDouble(data['dosage']),
      injectionSite: data['injection_site']?.toString(),
      injectionMethod: data['injection_method']?.toString(),
      administrator: data['administrator']?.toString(),
      vaccineManufacturer: data['vaccine_manufacturer']?.toString(),
      expiryDate: data['expiry_date']?.toString(),
      adverseReaction: data['adverse_reaction'] as bool?,
      reactionDetails: data['reaction_details']?.toString(),
      nextVaccinationDue: data['next_vaccination_due']?.toString(),
      cost: _parseInt(data['cost']),
      notes: data['notes']?.toString() ?? safeJson['description']?.toString(),
    );
  }

  // 전체 JSON (안 써도 됨)
  Map<String, dynamic> toJson() {
    return {
      'cow_id': cowId,
      'record_date': recordDate,
      ...toRecordDataJson(), // 재사용
    };
  }

  // 백엔드에 보내는 record_data 전용
  Map<String, dynamic> toRecordDataJson() {
    return {
      'vaccination_time': vaccinationTime,
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'vaccine_batch': vaccineBatch,
      'dosage': dosage,
      'injection_site': injectionSite,
      'injection_method': injectionMethod,
      'administrator': administrator,
      'vaccine_manufacturer': vaccineManufacturer,
      'expiry_date': expiryDate,
      'adverse_reaction': adverseReaction,
      'reaction_details': reactionDetails,
      'next_vaccination_due': nextVaccinationDue,
      'cost': cost,
      'notes': notes,
    };
  }
}
