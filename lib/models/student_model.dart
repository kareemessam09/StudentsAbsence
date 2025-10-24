import 'package:equatable/equatable.dart';

class StudentModel extends Equatable {
  final String id;
  final String studentCode; // Unique identifier (uppercase)
  final String name; // Student name (Indonesian: "nama" = "name")
  final String? nameArabic; // Arabic name
  final String? nameEnglish; // English name
  final String classId; // Reference to Class
  final bool isActive;
  final DateTime enrollmentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.studentCode,
    required this.name,
    this.nameArabic,
    this.nameEnglish,
    required this.classId,
    this.isActive = true,
    required this.enrollmentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // CopyWith method
  StudentModel copyWith({
    String? id,
    String? studentCode,
    String? nama,
    String? nameArabic,
    String? nameEnglish,
    String? classId,
    bool? isActive,
    DateTime? enrollmentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      name: nama ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      classId: classId ?? this.classId,
      isActive: isActive ?? this.isActive,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentCode': studentCode,
      'nama': name,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'class': classId,
      'isActive': isActive,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map for deserialization
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['_id'] as String? ?? map['id'] as String,
      studentCode: map['studentCode'] as String,
      name: map['nama'] as String,
      nameArabic: map['nameArabic'] as String?,
      nameEnglish: map['nameEnglish'] as String?,
      classId: map['class'] is String
          ? map['class'] as String
          : map['class']['_id'] as String,
      isActive: map['isActive'] as bool? ?? true,
      enrollmentDate: DateTime.parse(map['enrollmentDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Alias for fromMap (commonly used in API calls)
  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      StudentModel.fromMap(json);

  // Alias for toMap (commonly used in API calls)
  Map<String, dynamic> toJson() => toMap();

  // Helper getter for full student info
  String get fullInfo => '$name ($studentCode)';

  @override
  List<Object?> get props => [
    id,
    studentCode,
    name,
    nameArabic,
    nameEnglish,
    classId,
    isActive,
    enrollmentDate,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'StudentModel(id: $id, studentCode: $studentCode, nama: $name, classId: $classId, isActive: $isActive)';
  }
}
