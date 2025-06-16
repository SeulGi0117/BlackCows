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
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) {
        _logger.severe('Dio 요청 에러: ${e.message}');
        return handler.next(e);
      },
    ));
  }
}
