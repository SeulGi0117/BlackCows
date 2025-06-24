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

  Future<bool> login(String userId, String password, String loginUrl) async {
    try {
      final dio = DioClient().dio;

      final response = await dio.post(
        loginUrl,
        data: {
          'user_id': userId,    // 로그인용 아이디로 변경
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
    required String username,        // 사용자 이름/실명
    required String userId,          // 로그인용 아이디
    required String email,           // 이메일
    required String password,        // 비밀번호
    required String passwordConfirm, // 비밀번호 확인
    String? farmNickname,            // 목장 별명 (선택사항)
    required String signupUrl,
  }) async {
    try {
      final dio = DioClient().dio;

      final response = await dio.post(
        signupUrl,
        data: {
          'username': username,           // 사용자 이름/실명
          'user_id': userId,              // 로그인용 아이디
          'email': email,                 // 이메일
          'password': password,           // 비밀번호
          'password_confirm': passwordConfirm, // 비밀번호 확인
          'farm_nickname': farmNickname,  // 목장 별명 (선택사항)
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

  // 목장 이름 수정
  Future<bool> updateFarmName(String newFarmName) async {
    if (_accessToken == null) {
      _logger.warning('목장 이름 수정 실패: 로그인되지 않음');
      return false;
    }

    try {
      final dio = DioClient().dio;
      
      _logger.info('=== 목장 이름 수정 요청 시작 ===');
      _logger.info('새로운 목장 이름: $newFarmName');
      _logger.info('요청 데이터: ${{'farm_nickname': newFarmName}}');

      final response = await dio.put(
        '/auth/update-farm-name',
        data: {'farm_nickname': newFarmName},
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      _logger.info('=== 서버 응답 ===');
      _logger.info('상태 코드: ${response.statusCode}');
      _logger.info('응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.info('응답 데이터 타입: ${data.runtimeType}');
        _logger.info('success 값: ${data['success']}');
        _logger.info('user 데이터 존재: ${data['user'] != null}');
        
        if (data['success'] == true && data['user'] != null) {
          // 사용자 정보 업데이트
          _logger.info('사용자 정보 업데이트 전 목장명: ${_currentUser?.farmNickname}');
          _currentUser = User.fromJson(data['user']);
          _logger.info('사용자 정보 업데이트 후 목장명: ${_currentUser?.farmNickname}');
          notifyListeners();
          _logger.info('목장 이름 수정 성공: $newFarmName');
          return true;
        } else {
          _logger.warning('응답 구조 문제: success=${data['success']}, user=${data['user']}');
          return false;
        }
      }
      
      _logger.warning('목장 이름 수정 실패: ${response.statusCode} - ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.severe('=== Dio 에러 발생 ===');
      _logger.severe('에러 타입: ${e.type}');
      _logger.severe('에러 메시지: ${e.message}');
      _logger.severe('응답 상태코드: ${e.response?.statusCode}');
      _logger.severe('응답 데이터: ${e.response?.data}');
      return false;
    } catch (e) {
      _logger.severe('=== 예상치 못한 에러 ===');
      _logger.severe('에러: $e');
      return false;
    }
  }

  // 회원 탈퇴
  Future<bool> deleteAccount(String password) async {
    if (_accessToken == null) {
      _logger.warning('회원 탈퇴 실패: 로그인되지 않음');
      return false;
    }

    try {
      final dio = DioClient().dio;
      
      _logger.info('=== 회원 탈퇴 요청 시작 ===');
      _logger.info('요청 데이터: password=[HIDDEN], confirmation=DELETE');

      final response = await dio.delete(
        '/auth/delete-account',
        data: {
          'password': password,
          'confirmation': 'DELETE',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      _logger.info('=== 서버 응답 ===');
      _logger.info('상태 코드: ${response.statusCode}');
      _logger.info('응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.info('success 값: ${data['success']}');
        
        if (data['success'] == true) {
          // 모든 사용자 데이터 삭제
          clearUser();
          await clearTokenFromStorage();
          _logger.info('회원 탈퇴 성공');
          return true;
        } else {
          _logger.warning('탈퇴 실패: success=${data['success']}');
          return false;
        }
      }
      
      _logger.warning('회원 탈퇴 실패: ${response.statusCode} - ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.severe('=== 회원 탈퇴 Dio 에러 ===');
      _logger.severe('에러 타입: ${e.type}');
      _logger.severe('에러 메시지: ${e.message}');
      _logger.severe('응답 상태코드: ${e.response?.statusCode}');
      _logger.severe('응답 데이터: ${e.response?.data}');
      return false;
    } catch (e) {
      _logger.severe('=== 회원 탈퇴 예상치 못한 에러 ===');
      _logger.severe('에러: $e');
      return false;
    }
  }
}