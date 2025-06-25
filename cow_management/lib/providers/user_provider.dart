import 'package:flutter/material.dart';
import 'package:cow_management/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/services/dio_client.dart';
import 'package:logging/logging.dart';

// 로그인 에러 타입 정의
enum LoginErrorType {
  success,
  invalidCredentials,  // 아이디/비밀번호 오류
  serverError,         // 서버 오류
  networkError,        // 네트워크 연결 오류
  timeout,             // 타임아웃
  rateLimited,         // 요청 제한
  unknown              // 알 수 없는 오류
}

// 로그인 결과 클래스
class LoginResult {
  final bool success;
  final LoginErrorType errorType;
  final String message;

  LoginResult({
    required this.success,
    this.errorType = LoginErrorType.success,
    this.message = '',
  });
}

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
    // 로그아웃/계정전환 시 CowProvider 등 사용자별 데이터도 초기화 필요:
    // 예시: Provider.of<CowProvider>(context, listen: false).clearAll();
  }

  void markWelcomeShown() {
    _shouldShowWelcome = false;
    notifyListeners();
  }

  Future<LoginResult> loginWithResult(String userId, String password, String loginUrl) async {
    try {
      _logger.info('로그인 시도: $userId');
      final dio = DioClient().dio;

      final response = await dio.post(
        loginUrl,
        data: {
          'user_id': userId,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 응답 데이터 null 체크
        if (data == null) {
          _logger.warning('로그인 응답 데이터가 null입니다');
          return LoginResult(
            success: false,
            errorType: LoginErrorType.serverError,
            message: '서버 응답이 올바르지 않습니다.',
          );
        }

        // 필수 필드 존재 확인
        if (data['user'] == null || data['access_token'] == null || data['refresh_token'] == null) {
          _logger.warning('로그인 응답에 필수 필드가 누락됨: ${data.keys.toList()}');
          return LoginResult(
            success: false,
            errorType: LoginErrorType.serverError,
            message: '서버 응답 형식이 올바르지 않습니다.',
          );
        }

        try {
          _currentUser = User.fromJson(data['user']);
          _accessToken = data['access_token'];
          _refreshToken = data['refresh_token'];
          
          // 토큰 저장을 백그라운드에서 처리
          saveTokenToStorage(_accessToken!).catchError((error) {
            _logger.warning('토큰 저장 실패: $error');
          });

          _shouldShowWelcome = true;
          notifyListeners();

          _logger.info('로그인 성공: ${_currentUser?.username}');
          return LoginResult(success: true, message: '로그인 성공');
        } catch (e) {
          _logger.warning('사용자 데이터 파싱 실패: $e');
          return LoginResult(
            success: false,
            errorType: LoginErrorType.serverError,
            message: '사용자 정보를 처리하는 중 오류가 발생했습니다.',
          );
        }
      } else {
        _logger.warning('로그인 실패: ${response.statusCode}');
        return LoginResult(
          success: false,
          errorType: LoginErrorType.invalidCredentials,
          message: '아이디 또는 비밀번호가 올바르지 않습니다.',
        );
      }
    } on DioException catch (e) {
      _logger.warning('로그인 Dio 에러: ${e.type} - ${e.message}');
      
      // 서버 연결 문제 구분
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.timeout,
          message: '서버 연결 시간이 초과되었습니다.',
        );
      }
      
      if (e.type == DioExceptionType.connectionError ||
          e.message?.contains('SocketException') == true ||
          e.message?.contains('Connection refused') == true ||
          e.message?.contains('Network is unreachable') == true) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.serverError,
          message: '서버에 연결할 수 없습니다.',
        );
      }
      
      if (e.response?.statusCode == 401) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.invalidCredentials,
          message: '아이디 또는 비밀번호가 올바르지 않습니다.',
        );
      }
      
      if (e.response?.statusCode == 429) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.rateLimited,
          message: '너무 많은 로그인 시도. 잠시 후 다시 시도해주세요.',
        );
      }
      
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.serverError,
          message: '서버에 오류가 발생했습니다.',
        );
      }
      
      return LoginResult(
        success: false,
        errorType: LoginErrorType.networkError,
        message: '네트워크 연결을 확인해주세요.',
      );
    } catch (e) {
      _logger.severe('예상치 못한 로그인 에러: $e');
      return LoginResult(
        success: false,
        errorType: LoginErrorType.unknown,
        message: '예상치 못한 오류가 발생했습니다.',
      );
    }
  }

  // 기존 login 메서드 (호환성 유지)
  Future<bool> login(String userId, String password, String loginUrl) async {
    final result = await loginWithResult(userId, password, loginUrl);
    return result.success;
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
    // 로그아웃 시 CowProvider 등 사용자별 데이터도 초기화 필요:
    // 예시: Provider.of<CowProvider>(context, listen: false).clearAll();
  }

  Future<void> clearTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    } catch (e) {
      _logger.warning('토큰 삭제 실패: $e');
    }
  }

  Future<void> saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } catch (e) {
      _logger.warning('토큰 저장 실패: $e');
    }
  }

  Future<String?> loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      _logger.warning('토큰 로드 실패: $e');
      return null;
    }
  }

  // 자동 로그인 체크 (앱 시작 시)
  Future<bool> checkAutoLogin() async {
    try {
      final token = await loadTokenFromStorage();
      if (token == null || token.isEmpty) {
        return false;
      }

      // 토큰이 있으면 임시로 설정하고 사용자 정보 확인
      _accessToken = token;
      
      final dio = DioClient().dio;
      final response = await dio.get(
        '/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        _currentUser = User.fromJson(userData['user']);
        _shouldShowWelcome = false; // 자동 로그인 시에는 환영 메시지 표시 안함
        notifyListeners();
        
        _logger.info('자동 로그인 성공: ${_currentUser?.username}');
        return true;
      } else {
        // 토큰이 유효하지 않으면 삭제
        await clearTokenFromStorage();
        _accessToken = null;
        return false;
      }
    } catch (e) {
      _logger.warning('자동 로그인 실패: $e');
      // 에러 발생 시 토큰 삭제
      await clearTokenFromStorage();
      _accessToken = null;
      return false;
    }
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