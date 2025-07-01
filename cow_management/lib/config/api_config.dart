import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // 웹에서는 컴파일 타임 환경변수 사용
      return const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://your-default-api.com');
    } else {
      return dotenv.env['API_BASE_URL'] ?? 'https://your-default-api.com';
    }
  }
} 