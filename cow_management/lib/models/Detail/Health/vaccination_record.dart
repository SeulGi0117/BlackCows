class VaccinationRecord {
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

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      cowId: json['cow_id'] ?? '', // 안전하게 처리
      recordDate: json['record_date'] ?? '',
      vaccinationTime: json['vaccination_time'],
      vaccineName: json['vaccine_name'],
      vaccineType: json['vaccine_type'],
      vaccineBatch: json['vaccine_batch'],
      dosage: json['dosage']?.toDouble(),
      injectionSite: json['injection_site'],
      injectionMethod: json['injection_method'],
      administrator: json['administrator'],
      vaccineManufacturer: json['vaccine_manufacturer'],
      expiryDate: json['expiry_date'],
      adverseReaction: json['adverse_reaction'],
      reactionDetails: json['reaction_details'],
      nextVaccinationDue: json['next_vaccination_due'],
      cost: json['cost'],
      notes: json['notes'],
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
