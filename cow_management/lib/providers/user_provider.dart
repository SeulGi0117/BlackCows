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

  // 실제 서버와 연동하는 로그인 함수
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
      print('요청 데이터: username=$username, password=$password');
      print('응답 상태코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

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

  // 로그아웃 처리
  void logout() {
    _currentUser = null;
    notifyListeners();
    print('로그아웃');
  }
}
