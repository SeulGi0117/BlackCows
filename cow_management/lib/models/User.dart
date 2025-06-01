class User {
  final String username;
  final String password;
  final String user_email;

  User({
    required this.username,
    required this.password,
    required this.user_email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      user_email: json['user_email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'user_email': user_email,
    };
  }
}
