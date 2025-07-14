import 'package:flutter/foundation.dart';

enum NotificationType {
  // 할일
  taskDueSoon,
  taskOverdue,
  taskCompleted,
  taskCreated,
  taskAssigned,

  // 젖소 관리
  cowRegistered,
  cowUpdated,
  cowDeleted,
  cowFavoriteAdded,
  cowFavoriteRemoved,

  // 착유
  milkingRecordCreated,
  milkingYieldLow,
  milkingYieldHigh,
  milkingMissed,
  milkingQualityIssue,
  milkingScheduleReminder,

  // 번식
  estrusDetected,
  estrusPredicted,
  inseminationScheduled,
  inseminationCompleted,
  pregnancyCheckDue,
  pregnancyConfirmed,
  pregnancyFailed,
  calvingPredicted,
  calvingImminent,
  calvingCompleted,
  calvingDifficulty,
  abortionDetected,
  dryOffScheduled,
  dryOffCompleted,

  // 건강
  healthCheckDue,
  healthCheckCompleted,
  healthIssueDetected,
  vaccinationDue,
  vaccinationCompleted,
  vaccinationOverdue,
  treatmentStarted,
  treatmentCompleted,
  treatmentFollowUp,
  diseaseDetected,
  diseaseRecovery,

  // 사료
  feedScheduleReminder,
  feedRecordCreated,
  feedQualityIssue,
  feedShortage,
  feedOrderDue,

  // 체중
  weightMeasurementDue,
  weightAbnormal,
  weightTargetReached,

  // 검사
  brucellaTestDue,
  brucellaTestResult,
  tuberculosisTestDue,
  tuberculosisTestResult,

  // 시스템
  systemMaintenance,
  securityAlert,
  welcome,
  accountCreated,
  accountUpdated,
  passwordChanged,
  loginAttempt,
  loginFailed,
  loginSuccess,

  // 통계
  dailySummary,
  weeklySummary,
  monthlySummary,
  performanceAlert,
  trendAnalysis,

  // 챗봇
  chatbotQuestionAnswered,
  chatbotSuggestion,

  // 기록
  recordCreated,
  recordUpdated,
  recordDeleted,
  recordMissing,

  // 특수
  emergencyAlert,
  weatherAlert,
  equipmentFailure,
  supplyShortage,
  veterinarianVisit,
  inspectionDue,

  // 알림 설정
  notificationSettingsUpdated,
  notificationTest,
}

enum NotificationPriority { low, medium, high, urgent }

enum NotificationStatus { unread, read, archived }

NotificationType notificationTypeFromString(String type) {
  return NotificationType.values.firstWhere(
    (e) => describeEnum(e) == type,
    orElse: () => NotificationType.notificationTest,
  );
}

NotificationPriority priorityFromString(String value) {
  return NotificationPriority.values.firstWhere(
    (e) => describeEnum(e) == value,
    orElse: () => NotificationPriority.medium,
  );
}

NotificationStatus statusFromString(String value) {
  return NotificationStatus.values.firstWhere(
    (e) => describeEnum(e) == value,
    orElse: () => NotificationStatus.unread,
  );
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationPriority priority;
  final NotificationStatus status;
  final Map<String, dynamic>? data;
  final String? relatedCowId;
  final String? relatedCowName;
  final String? relatedTaskId;
  final String? relatedRecordId;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final bool isActive;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.status,
    this.data,
    this.relatedCowId,
    this.relatedCowName,
    this.relatedTaskId,
    this.relatedRecordId,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
    required this.isActive,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: notificationTypeFromString(json['notification_type']),
      title: json['title'],
      message: json['message'],
      priority: priorityFromString(json['priority']),
      status: statusFromString(json['status']),
      data: json['data'],
      relatedCowId: json['related_cow_id'],
      relatedCowName: json['related_cow_name'],
      relatedTaskId: json['related_task_id'],
      relatedRecordId: json['related_record_id'],
      createdAt: DateTime.parse(json['created_at']),
      readAt:
          json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "notification_type": describeEnum(type),
      "title": title,
      "message": message,
      "priority": describeEnum(priority),
      "status": describeEnum(status),
      "data": data,
      "related_cow_id": relatedCowId,
      "related_cow_name": relatedCowName,
      "related_task_id": relatedTaskId,
      "related_record_id": relatedRecordId,
      "created_at": createdAt.toIso8601String(),
      "read_at": readAt?.toIso8601String(),
      "expires_at": expiresAt?.toIso8601String(),
      "is_active": isActive,
    };
  }

  AppNotification copyWith({
    NotificationStatus? status,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      priority: priority,
      status: status ?? this.status,
      data: data,
      relatedCowId: relatedCowId,
      relatedCowName: relatedCowName,
      relatedTaskId: relatedTaskId,
      relatedRecordId: relatedRecordId,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );
  }
}
