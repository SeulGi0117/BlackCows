import 'package:flutter/foundation.dart'; // Enum에 필요하면
import 'User.dart';

enum CowStatus { healthy, sick, danger }

class Cow {
  final String cow_name;
  final DateTime birthdate;
  final String breed;
  final CowStatus status;
  final User user;

  Cow({
    required this.cow_name,
    required this.birthdate,
    required this.breed,
    required this.status,
    required this.user,
  });

  factory Cow.fromJson(Map<String, dynamic> json) {
    return Cow(
      cow_name: json['cow_name'] ?? '',
      birthdate: DateTime.parse(json['birthdate']),
      breed: json['breed'] ?? '',
      status: _statusFromString(json['status']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cow_name': cow_name,
      'birthdate': birthdate.toIso8601String(),
      'breed': breed,
      'status': describeEnum(status), // enum → 문자열로 변환
      'user': user.toJson(),
    };
  }

  static CowStatus _statusFromString(String statusStr) {
    switch (statusStr) {
      case 'healthy':
        return CowStatus.healthy;
      case 'sick':
        return CowStatus.sick;
      case 'danger':
        return CowStatus.danger;
      default:
        throw ArgumentError('Unknown status: $statusStr');
    }
  }
}
