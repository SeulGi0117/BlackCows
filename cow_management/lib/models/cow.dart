import 'package:cow_management/models/Detail/feeding_record.dart';

enum CowStatus { healthy, danger, unknown }

enum HealthStatus { normal, warning, danger }

enum BreedingStatus { calf, heifer, pregnant, lactating, dry, breeding }

class Cow {
  final String id;
  final String name;
  final String earTagNumber;
  final String? sensorNumber;
  final DateTime? birthdate;
  final HealthStatus? healthStatus;
  final BreedingStatus? breedingStatus;
  final String? breed;
  final String? notes;
  bool isFavorite;
  final String farmId;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<FeedingRecord> feedingRecords;
  // 기존 호환성을 위한 필드들
  final String number;
  final String sensor;
  final String date;
  final String status;
  final String milk;

  Cow({
    required this.id,
    required this.name,
    required this.earTagNumber,
    this.sensorNumber,
    this.birthdate,
    this.healthStatus,
    this.breedingStatus,
    this.breed,
    this.notes,
    this.isFavorite = false,
    this.feedingRecords = const [],
    required this.farmId,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    // 기존 호환성을 위한 기본값들
    String? number,
    String? sensor,
    String? date,
    String? status,
    String? milk,
  })  : number = number ?? earTagNumber,
        sensor = sensor ?? sensorNumber ?? '',
        date = date ?? (birthdate?.toIso8601String().split('T')[0] ?? ''),
        status = status ?? _healthStatusToString(healthStatus),
        milk = milk ?? '';

  static String _healthStatusToString(HealthStatus? healthStatus) {
    switch (healthStatus) {
      case HealthStatus.normal:
        return '양호';
      case HealthStatus.warning:
        return '경고';
      case HealthStatus.danger:
        return '위험';
      default:
        return '알 수 없음';
    }
  }

  static HealthStatus? _stringToHealthStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'normal':
        return HealthStatus.normal;
      case 'warning':
        return HealthStatus.warning;
      case 'danger':
        return HealthStatus.danger;
      default:
        return null;
    }
  }

  static BreedingStatus? _stringToBreedingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'calf':
        return BreedingStatus.calf;
      case 'heifer':
        return BreedingStatus.heifer;
      case 'pregnant':
        return BreedingStatus.pregnant;
      case 'lactating':
        return BreedingStatus.lactating;
      case 'dry':
        return BreedingStatus.dry;
      case 'breeding':
        return BreedingStatus.breeding;
      default:
        return null;
    }
  }

  factory Cow.fromJson(Map<String, dynamic> json) {
    return Cow(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      earTagNumber: json['ear_tag_number'] ?? '',
      sensorNumber: json['sensor_number'],
      birthdate: json['birthdate'] != null
          ? DateTime.tryParse(json['birthdate'])
          : null,
      healthStatus: _stringToHealthStatus(json['health_status']),
      breedingStatus: _stringToBreedingStatus(json['breeding_status']),
      breed: json['breed'],
      notes: json['notes'],
      isFavorite: json['is_favorite'] ?? false,
      farmId: json['farm_id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
      feedingRecords: json['feeding_records'] != null
          ? (json['feeding_records'] as List)
              .map((item) => FeedingRecord.fromJson(item))
              .toList()
          : [],
      // 기존 필드들 매핑
      number: json['number'],
      sensor: json['sensor'],
      date: json['date'],
      status: json['status'],
      milk: json['milk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ear_tag_number': earTagNumber,
      'sensor_number': sensorNumber,
      'birthdate': birthdate?.toIso8601String().split('T')[0],
      'health_status': healthStatus?.name,
      'breeding_status': breedingStatus?.name,
      'breed': breed,
      'notes': notes,
      'is_favorite': isFavorite,
      'farm_id': farmId,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      // 기존 호환성
      'number': number,
      'sensor': sensor,
      'date': date,
      'status': status,
      'milk': milk,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'ear_tag_number': earTagNumber,
      'name': name,
      if (birthdate != null)
        'birthdate': birthdate!.toIso8601String().split('T')[0],
      if (sensorNumber != null) 'sensor_number': sensorNumber,
      if (healthStatus != null) 'health_status': healthStatus!.name,
      if (breedingStatus != null) 'breeding_status': breedingStatus!.name,
      if (breed != null) 'breed': breed,
      if (notes != null) 'notes': notes,
    };
  }
}
