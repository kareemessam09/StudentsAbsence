import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // "receptionist" or "teacher"
  final String? className; // only for teachers

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.className,
  });

  // CopyWith method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? className,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      className: className ?? this.className,
    );
  }

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'className': className,
    };
  }

  // Create from Map for deserialization
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      className: map['className'] as String?,
    );
  }

  bool get isReceptionist => role == 'receptionist';
  bool get isTeacher => role == 'teacher';

  @override
  List<Object?> get props => [id, name, email, role, className];

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, className: $className)';
  }

  // Mock users for testing
  static List<UserModel> get mockUsers {
    return [
      const UserModel(
        id: '1',
        name: 'Sarah Johnson',
        email: 'sarah.receptionist@school.com',
        role: 'receptionist',
      ),
      const UserModel(
        id: '2',
        name: 'John Smith',
        email: 'john.receptionist@school.com',
        role: 'receptionist',
      ),
      const UserModel(
        id: '3',
        name: 'Dr. Emily Brown',
        email: 'emily.teacher@school.com',
        role: 'teacher',
        className: 'Class A',
      ),
      const UserModel(
        id: '4',
        name: 'Prof. Michael Davis',
        email: 'michael.teacher@school.com',
        role: 'teacher',
        className: 'Class B',
      ),
      const UserModel(
        id: '5',
        name: 'Ms. Lisa Wilson',
        email: 'lisa.teacher@school.com',
        role: 'teacher',
        className: 'Class C',
      ),
    ];
  }

  // Helper method to find user by email
  static UserModel? findByEmail(String email) {
    try {
      return mockUsers.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
}
