class TreatmentRecord {
  String? id;
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
    this.id,
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

  factory TreatmentRecord.fromJson(Map<String, dynamic> json) {
    final safeJson = Map<String, dynamic>.from(json);
    
    Map<String, dynamic> recordData = {};
    
    if (safeJson.containsKey('key_values') && safeJson['key_values'] != null) {
      final keyValues = Map<String, dynamic>.from(safeJson['key_values']);
      
      if (keyValues.containsKey('diagnosis')) {
        recordData['diagnosis'] = keyValues['diagnosis'];
      }
      if (keyValues.containsKey('cost')) {
        recordData['treatment_cost'] = keyValues['cost'];
      }
    }
    
    if (safeJson.containsKey('record_data') && safeJson['record_data'] != null) {
      final existingData = Map<String, dynamic>.from(safeJson['record_data']);
      recordData.addAll(existingData);
    }
    
    recordData.addAll(safeJson);

    return TreatmentRecord(
      id: recordData['id']?.toString(),
      cowId: recordData['cow_id']?.toString() ?? '',
      recordDate: recordData['record_date']?.toString() ?? '',
      treatmentTime: recordData['treatment_time']?.toString(),
      treatmentType: recordData['treatment_type']?.toString(),
      symptoms: recordData['symptoms'] != null ? List<String>.from(recordData['symptoms']) : null,
      diagnosis: recordData['diagnosis']?.toString(),
      medicationUsed: recordData['medication_used'] != null
          ? List<String>.from(recordData['medication_used'])
          : null,
      dosageInfo: recordData['dosage_info'] != null
          ? Map<String, String>.from((recordData['dosage_info'] as Map)
              .map((key, value) => MapEntry(key.toString(), value.toString())))
          : null,
      treatmentMethod: recordData['treatment_method']?.toString(),
      treatmentDuration: _parseInt(recordData['treatment_duration']),
      veterinarian: recordData['veterinarian']?.toString(),
      treatmentResponse: recordData['treatment_response']?.toString(),
      sideEffects: recordData['side_effects']?.toString(),
      followUpRequired: recordData['follow_up_required'],
      followUpDate: recordData['follow_up_date']?.toString(),
      treatmentCost: _parseInt(recordData['treatment_cost']),
      withdrawalPeriod: _parseInt(recordData['withdrawal_period']),
      notes: recordData['notes']?.toString() ?? recordData['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cow_id': cowId,
      'record_date': recordDate,
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
