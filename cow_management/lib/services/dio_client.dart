import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final _logger = Logger('DioClient');

  DioClient._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.path.contains('/auth/login') && 
            !options.path.contains('/auth/register')) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        return handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) {
        if (e.type == DioExceptionType.connectionTimeout) {
          _logger.warning('연결 타임아웃: ${e.requestOptions.uri}');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          _logger.warning('응답 타임아웃: ${e.requestOptions.uri}');
        } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
          _logger.severe('서버 에러 (${e.response!.statusCode}): ${e.requestOptions.uri}');
        }
        return handler.next(e);
      },
    ));
  }
}
