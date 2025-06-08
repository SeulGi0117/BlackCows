class User {
  final String? id;
  final String username;
  final String email;
  final String? farmName;
  final String? farmId;
  final String? createdAt;
  final bool isActive;

  User({
    this.id,
    required this.username,
    required this.email,
    this.farmName,
    this.farmId,
    this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      farmName: json['farm_name'],
      farmId: json['farm_id']?.toString(),
      createdAt: json['created_at'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'farm_name': farmName,
      'farm_id': farmId,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }
}
