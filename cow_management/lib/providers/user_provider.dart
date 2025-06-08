import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cow_management/models/User.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _shouldShowWelcome = false;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get shouldShowWelcome => _shouldShowWelcome;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _shouldShowWelcome = false;
    notifyListeners();
  }

  void markWelcomeShown() {
    _shouldShowWelcome = false;
    notifyListeners();
  }

  // 실제 서버와 연동하는 로그인 함수
  Future<bool> login(String username, String password, String loginUrl) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      print('요청 데이터: username=$username, password=$password');
      print('응답 상태코드: ${response.statusCode}');
      
      // UTF-8로 디코딩하여 응답 본문 출력
      final responseBody = utf8.decode(response.bodyBytes);
      print('응답 본문: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        _currentUser = User.fromJson(data['user']);
        _shouldShowWelcome = true; // 로그인 성공 시 환영 메시지 표시 플래그 설정
        notifyListeners();
        return true;
      } else {
        print('로그인 실패: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String farmName,
    required String signupUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(signupUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'farm_name': farmName,
        }),
      );

      print('회원가입 요청 응답 코드: ${response.statusCode}');
      print('회원가입 응답 본문: ${response.body}');

      if (response.statusCode == 201) {
        return true; // 회원가입 성공
      } else {
        return false; // 회원가입 실패
      }
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
      return false;
    }
  }

  // 로그아웃 처리
  void logout() {
    _currentUser = null;
    _shouldShowWelcome = false;
    notifyListeners();
    print('로그아웃');
  }
}
