import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    // dart-define으로 전달된 API_BASE_URL 우선 사용
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.blackcowsdairy.com'  // 웹/모바일 공통 기본값
    );
  }
} 