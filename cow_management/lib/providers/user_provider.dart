import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cow_management/models/User.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // ✅ 실제 서버와 연동하는 로그인 함수
  Future<bool> login(String username, String password, String loginUrl) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        notifyListeners();
        return true;
      } else {
        print('로그인 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
      return false;
    }
  }

  // ✅ 테스트용 가짜 로그인 함수
  Future<bool> loginTest(String username, String password) async {
    if (username == 'minji' && password == '1234') {
      _currentUser = User(
        username: username,
        password: password,
        user_email: '$username@example.com',
      );
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
