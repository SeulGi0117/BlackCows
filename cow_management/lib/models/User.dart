class User {
  final String username;
  final String email; // useremail → email
  final String password;
  final String? farmName; // 선택적 필드로 설정 가능
  final String? passwordConfirm; // 선택적 필드

  User({
    required this.username,
    required this.email,
    required this.password,
    this.farmName,
    this.passwordConfirm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      farmName: json['farm_name'],
      passwordConfirm: json['password_confirm'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      if (farmName != null) 'farm_name': farmName,
      if (passwordConfirm != null) 'password_confirm': passwordConfirm,
    };
  }
}
