import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../config/service_locator.dart';
import '../utils/app_logger.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  // Get services from service locator
  final AuthService _authService = getIt<AuthService>();
  final UserService _userService = getIt<UserService>();
  final SocketService _socketService = getIt<SocketService>();
  final ApiService _apiService = getIt<ApiService>();

  // Get current user if authenticated
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is UserAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  // Check if user is logged in on app start
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authService.getSavedUser();
      if (user != null) {
        // Connect socket on app start if user is logged in
        final token = await _apiService.getToken();
        if (token != null) {
          _socketService.connect(token);
        }

        emit(UserAuthenticated(user));
      }
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    emit(UserLoading());

    try {
      final result = await _authService.login(email: email, password: password);

      AppLogger.info('Login result: $result', tag: 'UserCubit');

      if (result['success']) {
        final user = result['user'] as UserModel;

        // Connect socket with user's token
        final token = await _apiService.getToken();
        if (token != null) {
          _socketService.connect(token);
        }

        emit(UserAuthenticated(user));
      } else {
        final errorMessage = result['message'] ?? 'Login failed';
        AppLogger.error('Login failed: $errorMessage', tag: 'UserCubit');
        emit(UserError(errorMessage));
      }
    } catch (e) {
      AppLogger.error('Login exception', tag: 'UserCubit', error: e);
      emit(UserError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Signup new user
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool isManager, // Kept for backward compatibility
    String? role, // New: direct role specification
  }) async {
    emit(UserLoading());

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        isManager: isManager,
        role: role, // Pass role to auth service
      );

      if (result['success']) {
        final user = result['user'] as UserModel;

        // Connect socket with user's token
        final token = await _apiService.getToken();
        if (token != null) {
          _socketService.connect(token);
        }

        emit(UserAuthenticated(user));
      } else {
        final errorMessage = result['message'] ?? 'Registration failed';
        AppLogger.error('Signup failed: $errorMessage', tag: 'UserCubit');
        emit(UserError(errorMessage));
      }
    } catch (e) {
      AppLogger.error('Signup exception', tag: 'UserCubit', error: e);
      emit(UserError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Logout user
  void logout() async {
    emit(UserLoading());

    try {
      await _authService.logout();
      // Disconnect socket on logout
      _socketService.disconnect();
      emit(UserUnauthenticated());
    } catch (e) {
      // Still logout locally even if API call fails
      _socketService.disconnect();
      emit(UserUnauthenticated());
    }
  }

  // Update user profile (name, email, assignedClasses)
  Future<void> updateProfile({
    String? name,
    String? email,
    List<String>? assignedClasses,
  }) async {
    final current = currentUser;
    if (current == null) {
      emit(const UserError('No user logged in'));
      return;
    }

    emit(UserLoading());

    try {
      final result = await _userService.updateMyProfile(
        name: name,
        email: email,
        assignedClasses: assignedClasses,
      );

      if (result['success']) {
        final updatedUser = result['user'] as UserModel;
        emit(UserAuthenticated(updatedUser));
      } else {
        emit(UserError(result['message'] ?? 'Update failed'));
        // Restore previous state
        emit(UserAuthenticated(current));
      }
    } catch (e) {
      emit(UserError('Failed to update profile: ${e.toString()}'));
      emit(UserAuthenticated(current));
    }
  }

  // Update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final current = currentUser;
    if (current == null) {
      emit(const UserError('No user logged in'));
      return;
    }

    emit(UserLoading());

    try {
      final result = await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['success']) {
        emit(UserAuthenticated(current));
      } else {
        emit(UserError(result['message'] ?? 'Password update failed'));
        emit(UserAuthenticated(current));
      }
    } catch (e) {
      emit(UserError('Failed to update password: ${e.toString()}'));
      emit(UserAuthenticated(current));
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => state is UserAuthenticated;
}
