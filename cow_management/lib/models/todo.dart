import 'package:flutter/material.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay? dueTime;
  final String priority;
  final String category;
  final String status;
  final List<String> assignedTo;
  final List<String> relatedCows;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final DateTime? completionDate;
  final String? completionNotes;
  final List<TodoAttachment> attachments;
  final List<String> tags;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    required this.priority,
    required this.category,
    required this.status,
    required this.assignedTo,
    required this.relatedCows,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.completionDate,
    this.completionNotes,
    required this.attachments,
    required this.tags,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    final dueDateTime = DateTime.parse(json['due_date'] as String);
    TimeOfDay? dueTime;
    if (json['due_time'] != null) {
      final timeParts = (json['due_time'] as String).split(':');
      dueTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: dueDateTime,
      dueTime: dueTime,
      priority: json['priority'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      assignedTo: List<String>.from(json['assigned_to'] as List),
      relatedCows: List<String>.from(json['related_cows'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'] as String)
          : null,
      completionNotes: json['completion_notes'] as String?,
      attachments: (json['attachments'] as List)
          .map((attachment) => TodoAttachment.fromJson(attachment as Map<String, dynamic>))
          .toList(),
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      if (dueTime != null)
        'due_time': '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}',
      'priority': priority,
      'category': category,
      'status': status,
      'assigned_to': assignedTo,
      'related_cows': relatedCows,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      if (completionDate != null) 'completion_date': completionDate!.toIso8601String(),
      if (completionNotes != null) 'completion_notes': completionNotes,
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
      'tags': tags,
    };
  }
}

class TodoAttachment {
  final String id;
  final String filename;
  final String url;
  final DateTime uploadedAt;

  TodoAttachment({
    required this.id,
    required this.filename,
    required this.url,
    required this.uploadedAt,
  });

  factory TodoAttachment.fromJson(Map<String, dynamic> json) {
    return TodoAttachment(
      id: json['id'] as String,
      filename: json['filename'] as String,
      url: json['url'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'url': url,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

// 할일 우선순위 상수
class TodoPriority {
  static const String high = 'high';
  static const String medium = 'medium';
  static const String low = 'low';
}

// 할일 상태 상수
class TodoStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

// 할일 카테고리 상수
class TodoCategory {
  static const String milking = 'milking';
  static const String healthCheck = 'health_check';
  static const String vaccination = 'vaccination';
  static const String treatment = 'treatment';
  static const String breeding = 'breeding';
  static const String feeding = 'feeding';
  static const String facility = 'facility';
} 