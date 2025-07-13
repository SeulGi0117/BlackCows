import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // dart-define으로 전달된 API_BASE_URL 우선 사용
    return const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://192.168.0.8:8000' // 웹/모바일 공통 기본값
        );
  }
}
