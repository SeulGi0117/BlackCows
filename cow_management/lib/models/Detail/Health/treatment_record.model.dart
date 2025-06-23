class TreatmentRecord {
  String cowId;
  String recordDate;
  String? treatmentTime;
  String? treatmentType;
  List<String>? symptoms;
  String? diagnosis;
  List<String>? medicationUsed;
  Map<String, String>? dosageInfo;
  String? treatmentMethod;
  int? treatmentDuration;
  String? veterinarian;
  String? treatmentResponse;
  String? sideEffects;
  bool? followUpRequired;
  String? followUpDate;
  int? treatmentCost;
  int? withdrawalPeriod;
  String? notes;

  TreatmentRecord({
    required this.cowId,
    required this.recordDate,
    this.treatmentTime,
    this.treatmentType,
    this.symptoms,
    this.diagnosis,
    this.medicationUsed,
    this.dosageInfo,
    this.treatmentMethod,
    this.treatmentDuration,
    this.veterinarian,
    this.treatmentResponse,
    this.sideEffects,
    this.followUpRequired,
    this.followUpDate,
    this.treatmentCost,
    this.withdrawalPeriod,
    this.notes,
  });

  factory TreatmentRecord.empty() {
    return TreatmentRecord(
      cowId: '',
      recordDate: '',
      treatmentTime: null,
      treatmentType: null,
      symptoms: null,
      diagnosis: null,
      medicationUsed: null,
      dosageInfo: null,
      treatmentMethod: null,
      treatmentDuration: null,
      veterinarian: null,
      treatmentResponse: null,
      sideEffects: null,
      followUpRequired: null,
      followUpDate: null,
      treatmentCost: null,
      withdrawalPeriod: null,
      notes: null,
    );
  }

  factory TreatmentRecord.fromJson(Map<String, dynamic> json) {
    return TreatmentRecord(
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      treatmentTime: json['treatment_time'],
      treatmentType: json['treatment_type'],
      symptoms:
          json['symptoms'] != null ? List<String>.from(json['symptoms']) : null,
      diagnosis: json['diagnosis'],
      medicationUsed: json['medication_used'] != null
          ? List<String>.from(json['medication_used'])
          : null,
      dosageInfo: json['dosage_info'] != null
          ? Map<String, String>.from(json['dosage_info'])
          : null,
      treatmentMethod: json['treatment_method'],
      treatmentDuration: json['treatment_duration'],
      veterinarian: json['veterinarian'],
      treatmentResponse: json['treatment_response'],
      sideEffects: json['side_effects'],
      followUpRequired: json['follow_up_required'],
      followUpDate: json['follow_up_date'],
      treatmentCost: json['treatment_cost'],
      withdrawalPeriod: json['withdrawal_period'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toRecordDataJson() {
    return {
      if (treatmentTime != null) 'treatment_time': treatmentTime,
      if (treatmentType != null) 'treatment_type': treatmentType,
      if (symptoms != null) 'symptoms': symptoms,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (medicationUsed != null) 'medication_used': medicationUsed,
      if (dosageInfo != null) 'dosage_info': dosageInfo,
      if (treatmentMethod != null) 'treatment_method': treatmentMethod,
      if (treatmentDuration != null) 'treatment_duration': treatmentDuration,
      if (veterinarian != null) 'veterinarian': veterinarian,
      if (treatmentResponse != null) 'treatment_response': treatmentResponse,
      if (sideEffects != null) 'side_effects': sideEffects,
      if (followUpRequired != null) 'follow_up_required': followUpRequired,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (treatmentCost != null) 'treatment_cost': treatmentCost,
      if (withdrawalPeriod != null) 'withdrawal_period': withdrawalPeriod,
      if (notes != null) 'notes': notes,
    };
  }
}
