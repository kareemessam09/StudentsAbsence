import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final _uuid = const Uuid();
  final List<UserModel> _users = List.from(UserModel.mockUsers);

  // Get current user if authenticated
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is UserAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    emit(UserLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user by email (simulated authentication)
      final user = _users.where((u) => u.email == email).firstOrNull;

      if (user != null) {
        // In a real app, you'd verify the password here
        // For now, accept any non-empty password
        if (password.isNotEmpty) {
          emit(UserAuthenticated(user));
        } else {
          emit(const UserError('Invalid password'));
        }
      } else {
        emit(const UserError('User not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  // Signup new user
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? className,
  }) async {
    emit(UserLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if email already exists
      final existingUser = _users.where((u) => u.email == email).firstOrNull;
      if (existingUser != null) {
        emit(const UserError('Email already exists'));
        return;
      }

      // Validate role
      if (role != 'receptionist' && role != 'teacher') {
        emit(const UserError('Invalid role'));
        return;
      }

      // Validate className for teachers
      if (role == 'teacher' && (className == null || className.isEmpty)) {
        emit(const UserError('Class name is required for teachers'));
        return;
      }

      // Create new user
      final newUser = UserModel(
        id: _uuid.v4(),
        name: name,
        email: email,
        role: role,
        className: className,
      );

      // Add to users list (simulated database)
      _users.add(newUser);

      // Auto-login after signup
      emit(UserAuthenticated(newUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  // Update user's managed class (for teachers)
  Future<void> updateClassName(String newClassName) async {
    final current = currentUser;
    if (current == null) {
      emit(const UserError('No user logged in'));
      return;
    }

    if (!current.isTeacher) {
      emit(const UserError('Only teachers can change their class'));
      return;
    }

    if (newClassName.isEmpty) {
      emit(const UserError('Class name cannot be empty'));
      return;
    }

    emit(UserLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update user in the list
      final updatedUser = current.copyWith(className: newClassName);
      final index = _users.indexWhere((u) => u.id == current.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      emit(UserAuthenticated(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
      // Restore previous state
      emit(UserAuthenticated(current));
    }
  }

  // Update user profile (name, email)
  Future<void> updateProfile({String? name, String? email}) async {
    final current = currentUser;
    if (current == null) {
      emit(const UserError('No user logged in'));
      return;
    }

    emit(UserLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if new email already exists (if changing email)
      if (email != null && email != current.email) {
        final existingUser = _users
            .where((u) => u.email == email && u.id != current.id)
            .firstOrNull;
        if (existingUser != null) {
          emit(const UserError('Email already exists'));
          emit(UserAuthenticated(current));
          return;
        }
      }

      // Update user
      final updatedUser = current.copyWith(name: name, email: email);

      final index = _users.indexWhere((u) => u.id == current.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      emit(UserAuthenticated(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
      // Restore previous state
      emit(UserAuthenticated(current));
    }
  }

  // Logout
  void logout() {
    emit(UserUnauthenticated());
  }

  // Check if user is authenticated
  bool get isAuthenticated => state is UserAuthenticated;

  // Get all users (for debugging)
  List<UserModel> get allUsers => List.unmodifiable(_users);
}
