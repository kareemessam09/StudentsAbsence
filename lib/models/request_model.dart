import 'package:flutter/material.dart';

@immutable
class RequestModel {
  final String id;
  final String studentName;
  final String className;
  final String status; // 'pending', 'accepted', 'not_found'
  final String createdBy;
  final DateTime createdAt;

  const RequestModel({
    required this.id,
    required this.studentName,
    required this.className,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  // Factory constructor to create RequestModel from JSON
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      className: json['className'] ?? '',
      status: json['status'] ?? 'pending',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert RequestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'className': className,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // CopyWith method for immutability
  RequestModel copyWith({
    String? id,
    String? studentName,
    String? className,
    String? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return RequestModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      className: className ?? this.className,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isNotFound => status == 'not_found';

  Color getStatusColor() {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'not_found':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'not_found':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.access_time;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'not_found':
        return 'Not Found';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  // Helper method to format time as string
  String getFormattedTime() {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  String toString() {
    return 'RequestModel(id: $id, studentName: $studentName, className: $className, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
