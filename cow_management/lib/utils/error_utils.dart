import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorUtils {
  static final Logger _logger = Logger('ErrorUtils');

  /// 네트워크 관련 오류인지 확인하는 함수 (서버 연결 오류 + 모든 네트워크 오류)
  static bool isNetworkError(dynamic error) {
    // DioException 체크
    if (error is DioException) {
      // 모든 네트워크 관련 오류 타입들
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.badCertificate ||
          error.type == DioExceptionType.cancel) {
        return true;
      }
      
      // 서버 오류 상태 코드들 (4xx, 5xx)
      if (error.response?.statusCode != null && error.response!.statusCode! >= 400) {
        return true;
      }
      
      // 네트워크 관련 에러 메시지들
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('connection') ||
          message.contains('socket') ||
          message.contains('network') ||
          message.contains('timeout') ||
          message.contains('refused') ||
          message.contains('failed') ||
          message.contains('unreachable') ||
          message.contains('host') ||
          message.contains('dns') ||
          message.contains('certificate') ||
          message.contains('ssl') ||
          message.contains('tls') ||
          message.contains('handshake') ||
          message.contains('protocol')) {
        return true;
      }
    }
    
    // 다양한 네트워크 예외들 체크
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('clientexception') ||
        errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('write failed') ||
        errorString.contains('read failed') ||
        errorString.contains('host lookup failed') ||
        errorString.contains('certificate') ||
        errorString.contains('handshake') ||
        errorString.contains('원격 컴퓨터가 네트워크 연결을 거부') ||
        errorString.contains('원격 호스트에 의해 강제로 끊겼습니다') ||
        errorString.contains('connection error') ||
        errorString.contains('no route to host') ||
        errorString.contains('connection timed out') ||
        errorString.contains('name or service not known') ||
        errorString.contains('temporary failure in name resolution')) {
      return true;
    }
    
    return false;
  }

  /// 서버 연결 오류인지 확인하는 함수 (기존 호환성 유지)
  static bool isServerConnectionError(dynamic error) {
    return isNetworkError(error);
  }

  /// 네트워크 오류 발생 시 개발팀 문의 다이얼로그 표시
  static void showNetworkErrorDialog(BuildContext context, {String? customMessage, dynamic error}) {
    if (!context.mounted) return;
    
    // 인증 오류(401/307) 안내 메시지 추가
    if (error is DioException && (error.response?.statusCode == 401 || error.response?.statusCode == 307)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                const Expanded(child: Text('인증 오류')),
              ],
            ),
            content: const Text('로그인이 만료되었습니다.\n다시 로그인 해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          );
        },
      );
      return;
    }
    
    // 오류 타입 분석
    String errorType = '네트워크 연결 오류';
    List<String> possibleCauses = [];
    String additionalInfo = '';
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          errorType = '연결 시간 초과';
          possibleCauses = ['서버 응답 시간 초과', '네트워크 속도 느림', '서버 과부하'];
          break;
        case DioExceptionType.sendTimeout:
          errorType = '전송 시간 초과';
          possibleCauses = ['데이터 전송 시간 초과', '네트워크 불안정'];
          break;
        case DioExceptionType.receiveTimeout:
          errorType = '수신 시간 초과';
          possibleCauses = ['서버 응답 시간 초과', '네트워크 불안정'];
          break;
        case DioExceptionType.badCertificate:
          errorType = 'SSL 인증서 오류';
          possibleCauses = ['서버 인증서 문제', 'SSL/TLS 설정 오류'];
          break;
        case DioExceptionType.connectionError:
          errorType = '연결 오류';
          possibleCauses = ['서버 연결 불가', '네트워크 연결 문제', 'DNS 문제'];
          break;
        default:
          if (error.response?.statusCode != null) {
            final statusCode = error.response!.statusCode!;
            if (statusCode >= 500) {
              errorType = '서버 일시적 오류';
              possibleCauses = [
                '서버가 일시적으로 응답할 수 없는 상태입니다',
                '잠시 후 다시 시도해주세요',
                '문제가 지속되면 개발팀에 문의해주세요'
              ];
              additionalInfo = '현재 서버에 일시적인 문제가 발생했습니다.\n잠시 후 자동으로 복구될 예정이니 잠시만 기다려주세요.';
            } else if (statusCode >= 400) {
              errorType = '요청 오류';
              possibleCauses = ['잘못된 요청', '인증 문제', '권한 없음'];
            }
          }
      }
    } else {
      // 기타 네트워크 오류들
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('socket')) {
        errorType = '소켓 연결 오류';
        possibleCauses = ['네트워크 연결 끊김', '방화벽 차단', '포트 접근 불가'];
      } else if (errorString.contains('dns') || errorString.contains('host lookup')) {
        errorType = 'DNS 조회 오류';
        possibleCauses = ['도메인 이름 해석 실패', 'DNS 서버 문제'];
      } else if (errorString.contains('certificate')) {
        errorType = '인증서 오류';
        possibleCauses = ['SSL 인증서 만료', '인증서 검증 실패'];
      }
    }
    
    // 기본 원인들 추가
    if (possibleCauses.isEmpty) {
      possibleCauses = ['서버 연결 불가', '네트워크 연결 문제', '서버 점검 중', '인터넷 연결 상태 확인 필요'];
    }
    
    showDialog(
      context: context,
      barrierDismissible: false, // 뒤로가기로 닫히지 않도록
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text(errorType)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (additionalInfo.isNotEmpty) ...[
                  Text(
                    additionalInfo,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  '가능한 원인:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...possibleCauses.map((cause) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $cause'),
                )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.support_agent, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            '개발팀 지원',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '문제가 지속되면 개발팀에 문의해주세요.\n오류 상황과 함께 신속하게 해결해드리겠습니다.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'support@blackcowsdairy.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _copyEmailToClipboard(context);
              },
              child: const Text('이메일 복사'),
            ),
          ],
        );
      },
    );
  }

  /// 서버 오류 다이얼로그 (기존 호환성 유지)
  static void showServerErrorDialog(BuildContext context, {String? customMessage}) {
    showNetworkErrorDialog(context, customMessage: customMessage);
  }

  /// 문의 페이지 열기
  static Future<void> _launchContactPage() async {
    const url = 'https://blackcows-team.github.io/blackcows-privacy/contact.html';
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _logger.warning('문의 페이지 URL을 열 수 없습니다: $url');
      }
    } catch (e) {
      _logger.warning('문의 페이지 열기 실패: $e');
    }
  }

  /// 모든 오류를 처리하고 네트워크 오류인 경우 개발자 문의 다이얼로그 표시
  static void handleError(BuildContext context, dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
    String defaultMessage = '오류가 발생했습니다',
  }) {
    _logger.severe('오류 처리: $error');
    
    if (!context.mounted) return;
    
    // 네트워크 오류인 경우 개발자 문의 다이얼로그 표시
    if (isNetworkError(error)) {
      showNetworkErrorDialog(context, customMessage: customMessage, error: error);
      return;
    }
    
    // 일반적인 오류인 경우 스낵바 표시
    if (showSnackBar) {
      final message = customMessage ?? defaultMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '개발팀 문의',
            textColor: Colors.white,
            onPressed: () => showNetworkErrorDialog(context, customMessage: message, error: error),
          ),
        ),
      );
    }
  }

  /// 이메일 주소 클립보드 복사
  static Future<void> _copyEmailToClipboard(BuildContext context) async {
    try {
      await Clipboard.setData(const ClipboardData(text: 'support@blackcowsdairy.com'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개발팀 이메일 주소가 클립보드에 복사되었습니다.\n이메일 앱에서 붙여넣기 하세요.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.warning('클립보드 복사 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복사에 실패했습니다. 수동으로 입력해주세요: support@blackcowsdairy.com'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// 서버 오류 메시지 추출
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        if (error.response!.data is Map && error.response!.data.containsKey('detail')) {
          return error.response!.data['detail'].toString();
        }
        if (error.response!.data is Map && error.response!.data.containsKey('message')) {
          return error.response!.data['message'].toString();
        }
      }
      return error.message ?? error.toString();
    }
    
    return error.toString();
  }

  /// 네트워크 오류 타입별 사용자 친화적 메시지 반환
  static String getNetworkErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '서버 연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.';
        case DioExceptionType.sendTimeout:
          return '데이터 전송 시간이 초과되었습니다. 다시 시도해주세요.';
        case DioExceptionType.receiveTimeout:
          return '서버 응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
        case DioExceptionType.badCertificate:
          return '서버 인증서에 문제가 있습니다. 개발팀에 문의해주세요.';
        case DioExceptionType.connectionError:
          return '서버에 연결할 수 없습니다. 네트워크 연결을 확인해주세요.';
        case DioExceptionType.cancel:
          return '요청이 취소되었습니다.';
        default:
          if (error.response?.statusCode != null) {
            final statusCode = error.response!.statusCode!;
            if (statusCode >= 500) {
              return '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
            } else if (statusCode == 404) {
              return '요청한 정보를 찾을 수 없습니다.';
            } else if (statusCode == 401) {
              return '인증이 필요합니다. 다시 로그인해주세요.';
            } else if (statusCode == 403) {
              return '접근 권한이 없습니다.';
            } else if (statusCode >= 400) {
              return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
            }
          }
      }
    }
    
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket')) {
      return '네트워크 연결이 끊어졌습니다. 인터넷 연결을 확인해주세요.';
    } else if (errorString.contains('dns') || errorString.contains('host lookup')) {
      return '서버 주소를 찾을 수 없습니다. 네트워크 설정을 확인해주세요.';
    } else if (errorString.contains('certificate')) {
      return '보안 인증서에 문제가 있습니다. 개발팀에 문의해주세요.';
    }
    
    return '네트워크 연결에 문제가 발생했습니다. 인터넷 연결을 확인하고 다시 시도해주세요.';
  }
} 