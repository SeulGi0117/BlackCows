import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/notification.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:cow_management/providers/user_provider.dart';

class NotificationProvider with ChangeNotifier {
  final UserProvider userProvider;
  final List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  NotificationProvider({required this.userProvider});

  Dio get _dio => Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          "Authorization": "Bearer ${userProvider.accessToken ?? ''}",
        },
      ));

  /// 알림 목록 조회
  Future<void> fetchNotifications() async {
    final token = userProvider.accessToken;
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/api/notifications/');
      _notifications
        ..clear()
        ..addAll((response.data as List)
            .map((json) => AppNotification.fromJson(json)));
    } catch (e, stack) {
      debugPrint("[ERROR] fetchNotifications: $e\n$stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 읽지 않은 알림만 조회
  Future<List<AppNotification>> fetchUnreadNotifications() async {
    final token = userProvider.accessToken;
    if (token == null) return [];

    try {
      final response = await _dio.get('/api/notifications/unread');
      return (response.data as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e, stack) {
      debugPrint("[ERROR] fetchUnreadNotifications: $e\n$stack");
      return [];
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    final token = userProvider.accessToken;
    if (token == null) return;

    try {
      await _dio.patch('/api/notifications/$id/read');

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final original = _notifications[index];
        _notifications[index] = original.copyWith(
          status: NotificationStatus.read,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e, stack) {
      debugPrint("[ERROR] markAsRead: $e\n$stack");
    }
  }

  /// 전체 읽음 처리
  Future<void> markAllAsRead() async {
    final token = userProvider.accessToken;
    if (token == null) return;

    try {
      await _dio.patch('/api/notifications/read-all');
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(
          status: NotificationStatus.read,
          readAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e, stack) {
      debugPrint("[ERROR] markAllAsRead: $e\n$stack");
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(String id) async {
    final token = userProvider.accessToken;
    if (token == null) return;

    try {
      await _dio.delete('/api/notifications/$id');
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e, stack) {
      debugPrint("[ERROR] deleteNotification: $e\n$stack");
    }
  }

  /// 새로고침
  Future<void> refresh() async => await fetchNotifications();
}
