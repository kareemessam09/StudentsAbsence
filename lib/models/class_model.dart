import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String teacherId; // Reference to User (teacher)
  final List<String> studentIds; // References to Students
  final int capacity;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.teacherId,
    this.studentIds = const [],
    this.capacity = 30,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // CopyWith method
  ClassModel copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    List<String>? studentIds,
    int? capacity,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      studentIds: studentIds ?? this.studentIds,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacher': teacherId,
      'students': studentIds,
      'capacity': capacity,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map for deserialization
  factory ClassModel.fromMap(Map<String, dynamic> map) {
    // Handle teacher field which can be null, String (ID), or Object with _id
    String teacherIdValue = '';
    if (map['teacher'] != null) {
      if (map['teacher'] is String) {
        teacherIdValue = map['teacher'] as String;
      } else if (map['teacher'] is Map) {
        teacherIdValue = map['teacher']['_id'] as String;
      }
    }

    return ClassModel(
      id: map['_id'] as String? ?? map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      teacherId: teacherIdValue,
      studentIds: map['students'] is List
          ? (map['students'] as List).map((s) {
              if (s is String) return s;
              return s['_id'] as String;
            }).toList()
          : [],
      capacity: map['capacity'] as int? ?? 30,
      isActive: map['isActive'] as bool? ?? true,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Alias for fromMap (commonly used in API calls)
  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      ClassModel.fromMap(json);

  // Alias for toMap (commonly used in API calls)
  Map<String, dynamic> toJson() => toMap();

  // Virtual getters
  int get studentCount => studentIds.length;
  int get availableSpots => capacity - studentCount;
  bool get isFull => studentCount >= capacity;
  bool get hasAvailableSpots => availableSpots > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    teacherId,
    studentIds,
    capacity,
    isActive,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'ClassModel(id: $id, name: $name, teacher: $teacherId, students: ${studentIds.length}/$capacity)';
  }

  // Mock classes for testing
  static List<ClassModel> get mockClasses {
    final now = DateTime.now();
    final startDate = DateTime(2024, 1, 1);

    return [
      ClassModel(
        id: 'c1',
        name: 'Class A',
        description: 'Mathematics and Science - Grade 10',
        teacherId: '3', // Dr. Emily Brown
        studentIds: ['s1', 's2'],
        capacity: 30,
        isActive: true,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      ),
      ClassModel(
        id: 'c2',
        name: 'Class B',
        description: 'Languages and Arts - Grade 10',
        teacherId: '3', // Dr. Emily Brown
        studentIds: ['s3', 's4'],
        capacity: 30,
        isActive: true,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      ),
      ClassModel(
        id: 'c3',
        name: 'Class C',
        description: 'Sciences - Grade 11',
        teacherId: '4', // Prof. Michael Davis
        studentIds: ['s5', 's6'],
        capacity: 25,
        isActive: true,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      ),
      ClassModel(
        id: 'c4',
        name: 'Class D',
        description: 'Advanced Mathematics - Grade 11',
        teacherId: '5', // Ms. Lisa Wilson
        studentIds: ['s7'],
        capacity: 20,
        isActive: true,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      ),
      ClassModel(
        id: 'c5',
        name: 'Class E',
        description: 'Computer Science - Grade 12',
        teacherId: '5', // Ms. Lisa Wilson
        studentIds: ['s8'],
        capacity: 25,
        isActive: true,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Helper method to find class by ID
  static ClassModel? findById(String id) {
    try {
      return mockClasses.firstWhere((classData) => classData.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to find classes by teacher
  static List<ClassModel> findByTeacher(String teacherId) {
    return mockClasses
        .where((classData) => classData.teacherId == teacherId)
        .toList();
  }

  // Helper method to check if class can accept more students
  bool canAddStudent() {
    return isActive && hasAvailableSpots;
  }

  // Helper method to validate capacity
  bool validateCapacity(int newCapacity) {
    return newCapacity >= studentCount &&
        newCapacity >= 1 &&
        newCapacity <= 100;
  }
}
