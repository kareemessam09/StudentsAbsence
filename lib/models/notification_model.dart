import 'package:flutter/material.dart';

@immutable
class NotificationModel {
  final String id;
  final String from;
  final String to;
  final String studentId;
  final String? studentName;
  final String? studentNameArabic;
  final String classId;
  final String type; // 'request', 'response', 'message'
  final String status; // 'pending', 'present', 'absent'
  final String message;
  final String? responseMessage;
  final bool isRead;
  final DateTime? requestDate;
  final DateTime? responseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.from,
    required this.to,
    required this.studentId,
    this.studentName,
    this.studentNameArabic,
    required this.classId,
    required this.type,
    required this.status,
    required this.message,
    this.responseMessage,
    this.isRead = false,
    this.requestDate,
    this.responseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper function to extract ID from string or object
    String extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['_id'] ?? value['id'] ?? '';
      }
      return '';
    }

    // Extract student information if populated
    String? studentName;
    String? studentNameArabic;
    String studentId = '';

    final studentData = json['student'] ?? json['studentId'];
    if (studentData is Map<String, dynamic>) {
      studentId = extractId(studentData);
      studentName = studentData['nama'] as String?;
      studentNameArabic = studentData['nameArabic'] as String?;
    } else if (studentData is String) {
      studentId = studentData;
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      from: extractId(json['from']),
      to: extractId(json['to']),
      studentId: studentId,
      studentName: studentName,
      studentNameArabic: studentNameArabic,
      classId: extractId(json['class'] ?? json['classId']),
      type: json['type'] ?? 'request',
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
      responseMessage: json['responseMessage'],
      isRead: json['isRead'] ?? false,
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : null,
      responseDate: json['responseDate'] != null
          ? DateTime.parse(json['responseDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'studentId': studentId,
      'studentName': studentName,
      'studentNameArabic': studentNameArabic,
      'classId': classId,
      'type': type,
      'status': status,
      'message': message,
      'responseMessage': responseMessage,
      'isRead': isRead,
      'requestDate': requestDate?.toIso8601String(),
      'responseDate': responseDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method for immutability
  NotificationModel copyWith({
    String? id,
    String? from,
    String? to,
    String? studentId,
    String? studentName,
    String? studentNameArabic,
    String? classId,
    String? type,
    String? status,
    String? message,
    String? responseMessage,
    bool? isRead,
    DateTime? requestDate,
    DateTime? responseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNameArabic: studentNameArabic ?? this.studentNameArabic,
      classId: classId ?? this.classId,
      type: type ?? this.type,
      status: status ?? this.status,
      message: message ?? this.message,
      responseMessage: responseMessage ?? this.responseMessage,
      isRead: isRead ?? this.isRead,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPresent => status.toLowerCase() == 'present';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isResolved =>
      isPresent || isAbsent; // Resolved means either present or absent
  bool get isRequest => type.toLowerCase() == 'request';
  bool get isResponse => type.toLowerCase() == 'response';
  bool get isMessage => type.toLowerCase() == 'message';

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      default:
        return status;
    }
  }

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, from: $from, to: $to, studentId: $studentId, type: $type, status: $status, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
