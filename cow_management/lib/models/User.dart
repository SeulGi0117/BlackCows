class User {
  final String username;
  final String password;
  final String useremail;

  User({
    required this.username,
    required this.password,
    required this.useremail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      useremail: json['user_email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'user_email': useremail,
    };
  }
}
