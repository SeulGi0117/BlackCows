enum CowStatus { healthy, danger, unknown }

class Cow {
  final String id;
  final String name;
  final String number;
  final String sensor;
  final String date;
  final String status;
  final String milk;
  final DateTime birthdate;
  final String breed;
  bool isFavorite;

  Cow({
    required this.id,
    required this.name,
    required this.number,
    required this.sensor,
    required this.date,
    required this.status,
    required this.milk,
    required this.birthdate,
    required this.breed,
    this.isFavorite = false,
  });

  factory Cow.fromJson(Map<String, dynamic> json) {
    return Cow(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      sensor: json['sensor'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'unknown',
      milk: json['milk'] ?? '',
      birthdate: DateTime.tryParse(json['birthdate'] ?? '') ?? DateTime(2000),
      breed: json['breed'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'sensor': sensor,
      'date': date,
      'status': status,
      'milk': milk,
      'birthdate': birthdate.toIso8601String(),
      'breed': breed,
      'isFavorite': isFavorite,
    };
  }
}
