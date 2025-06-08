import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cow_management/models/User.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  bool _shouldShowWelcome = false;
  
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;
  bool get shouldShowWelcome => _shouldShowWelcome;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
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
        
        // 사용자 정보 저장
        _currentUser = User.fromJson(data['user']);
        
        // 토큰 저장
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        
        _shouldShowWelcome = true; // 로그인 성공 시 환영 메시지 표시 플래그 설정
        notifyListeners();
        
        print('로그인 성공: 토큰 저장됨');
        print('Access Token: ${_accessToken?.substring(0, 20)}...');
        
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
      print('회원가입 요청 데이터: username=$username, email=$email, farm_name=$farmName');
      
      final response = await http.post(
        Uri.parse(signupUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'farm_name': farmName,
        }),
      );

      print('회원가입 요청 응답 코드: ${response.statusCode}');
      
      // UTF-8로 디코딩하여 응답 본문 출력
      final responseBody = utf8.decode(response.bodyBytes);
      print('회원가입 응답 본문: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
    _accessToken = null;
    _refreshToken = null;
    _shouldShowWelcome = false;
    notifyListeners();
    print('로그아웃: 모든 데이터 삭제됨');
  }
}
