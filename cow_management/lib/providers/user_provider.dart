import 'package:flutter/material.dart';
import 'package:cow_management/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/services/dio_client.dart';
import 'package:logging/logging.dart';

class UserProvider with ChangeNotifier {
  final _logger = Logger('UserProvider');
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

  void setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await saveTokenToStorage(accessToken); // 저장하기
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

  Future<bool> login(String username, String password, String loginUrl) async {
    try {
      final dio = DioClient().dio;

      final response = await dio.post(
        loginUrl,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        _currentUser = User.fromJson(data['user']);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        await saveTokenToStorage(_accessToken!);

        _shouldShowWelcome = true;
        notifyListeners();

        _logger.info('로그인 성공: ${_accessToken?.substring(0, 20)}...');
        return true;
      } else {
        _logger.warning('로그인 실패: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      _logger.severe('로그인 에러: ${e.response?.data ?? e.message}');
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
      final dio = DioClient().dio;

      final response = await dio.post(
        signupUrl,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'farm_name': farmName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('✅ 회원가입 성공');
        return true;
      } else {
        _logger.warning('❌ 회원가입 실패: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      _logger.severe('❌ 회원가입 에러: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // 로그아웃 처리
  void logout() async {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _shouldShowWelcome = false;
    await clearTokenFromStorage();
    notifyListeners();
    _logger.info('로그아웃: 모든 데이터 삭제됨');
  }

  Future<void> clearTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<void> saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
