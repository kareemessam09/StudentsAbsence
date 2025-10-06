class RequestModel {
  final String id;
  final String studentName;
  final String className;
  final String status; // "pending", "accepted", "not_found"
  final String createdBy; // receptionist id
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.studentName,
    required this.className,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  // copyWith method for creating modified copies
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

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentName': studentName,
      'className': className,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map for deserialization
  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'] as String,
      studentName: map['studentName'] as String,
      className: map['className'] as String,
      status: map['status'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'RequestModel(id: $id, studentName: $studentName, className: $className, status: $status, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RequestModel &&
        other.id == id &&
        other.studentName == studentName &&
        other.className == className &&
        other.status == status &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentName.hashCode ^
        className.hashCode ^
        status.hashCode ^
        createdBy.hashCode ^
        createdAt.hashCode;
  }

  // Static mock requests for testing
  static List<RequestModel> get mockRequests {
    final now = DateTime.now();

    return [
      RequestModel(
        id: '1',
        studentName: 'Emma Wilson',
        className: 'Class A',
        status: 'pending',
        createdBy: '1', // Sarah Johnson (receptionist)
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      RequestModel(
        id: '2',
        studentName: 'Michael Brown',
        className: 'Class B',
        status: 'pending',
        createdBy: '1',
        createdAt: now.subtract(const Duration(minutes: 38)),
      ),
      RequestModel(
        id: '3',
        studentName: 'Sarah Davis',
        className: 'Class A',
        status: 'accepted',
        createdBy: '2', // John Smith (receptionist)
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      RequestModel(
        id: '4',
        studentName: 'James Miller',
        className: 'Class C',
        status: 'pending',
        createdBy: '1',
        createdAt: now.subtract(const Duration(minutes: 12)),
      ),
      RequestModel(
        id: '5',
        studentName: 'Olivia Garcia',
        className: 'Class B',
        status: 'not_found',
        createdBy: '2',
        createdAt: now.subtract(const Duration(minutes: 8)),
      ),
      RequestModel(
        id: '6',
        studentName: 'William Martinez',
        className: 'Class A',
        status: 'pending',
        createdBy: '1',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      RequestModel(
        id: '7',
        studentName: 'Sophia Anderson',
        className: 'Class C',
        status: 'accepted',
        createdBy: '2',
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      RequestModel(
        id: '8',
        studentName: 'Liam Taylor',
        className: 'Class B',
        status: 'pending',
        createdBy: '1',
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  } // Helper method to get only pending requests

  static List<RequestModel> get mockPendingRequests {
    return mockRequests
        .where((request) => request.status == 'pending')
        .toList();
  }

  // Helper method to format time as string
  String getFormattedTime() {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
