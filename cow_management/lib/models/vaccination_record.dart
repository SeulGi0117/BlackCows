class VaccinationRecord {
  final String id;
  final String cowId;
  final String recordDate;
  final String vaccineName;
  final String vaccineType;
  final String administeredBy;
  final String reaction;
  final String nextScheduledDate;
  final String notes;

  VaccinationRecord({
    required this.id,
    required this.cowId,
    required this.recordDate,
    required this.vaccineName,
    required this.vaccineType,
    required this.administeredBy,
    required this.reaction,
    required this.nextScheduledDate,
    required this.notes,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      vaccineName: json['vaccine_name'],
      vaccineType: json['vaccine_type'],
      administeredBy: json['administered_by'],
      reaction: json['reaction'],
      nextScheduledDate: json['next_scheduled_date'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cow_id': cowId,
      'record_date': recordDate,
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'administered_by': administeredBy,
      'reaction': reaction,
      'next_scheduled_date': nextScheduledDate,
      'notes': notes,
    };
  }
}
