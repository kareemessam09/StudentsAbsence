import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Authentication Service
/// Handles all authentication related API calls
class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Register a new user
  /// POST /auth/register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool isManager,
    String? role, // Optional: if provided, use this instead of isManager
  }) async {
    try {
      // Backend expects 'role' field
      // Priority: use provided role, otherwise convert isManager to role
      final String userRole = role ?? (isManager ? 'manager' : 'receptionist');

      final response = await _apiService.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'role': userRole,
        },
      );

      // Save token and user data
      // Backend response structure: { status, token, data: { user } }
      final token = response.data['token'];

      if (token == null) {
        return {
          'success': false,
          'message': 'Invalid response from server: missing token',
        };
      }

      final userData = response.data['data']?['user'] ?? response.data['user'];

      if (userData == null) {
        return {
          'success': false,
          'message': 'Invalid response from server: missing user data',
        };
      }

      final user = UserModel.fromJson(userData);

      await _apiService.saveToken(token);
      await _apiService.saveUserData(jsonEncode(user.toJson()));

      return {
        'success': true,
        'token': token,
        'user': user,
        'message': response.data['message'] ?? 'Registration successful',
      };
    } catch (e) {
      print('Register error: $e'); // Debug print
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Login user
  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      // Save token and user data
      // Backend response structure: { status, token, data: { user } }
      final token = response.data['token'];

      if (token == null) {
        return {
          'success': false,
          'message': 'Invalid response from server: missing token',
        };
      }

      final userData = response.data['data']?['user'] ?? response.data['user'];

      if (userData == null) {
        return {
          'success': false,
          'message': 'Invalid response from server: missing user data',
        };
      }

      final user = UserModel.fromJson(userData);

      await _apiService.saveToken(token);
      await _apiService.saveUserData(jsonEncode(user.toJson()));

      return {
        'success': true,
        'token': token,
        'user': user,
        'message': response.data['message'] ?? 'Login successful',
      };
    } catch (e) {
      print('Login error: $e'); // Debug print
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get current user
  /// GET /auth/me
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _apiService.get(ApiEndpoints.getMe);

      // Backend response structure: { status, data: { user } } or { user }
      final userData =
          response.data['data']?['user'] ??
          response.data['user'] ??
          response.data;
      final user = UserModel.fromJson(userData);

      // Update saved user data
      await _apiService.saveUserData(jsonEncode(user.toJson()));

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Logout user
  /// POST /auth/logout
  Future<Map<String, dynamic>> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);

      // Clear token and user data
      await _apiService.clearToken();

      return {'success': true, 'message': 'Logout successful'};
    } catch (e) {
      // Clear token anyway even if API call fails
      await _apiService.clearToken();

      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Update password
  /// PUT /auth/password
  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updatePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Password updated successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Request password reset
  /// POST /auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Reset link sent to your email',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Reset password with token
  /// POST /auth/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resetPassword(token), // Pass token to get endpoint string
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Password reset successful',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get saved user data
  Future<UserModel?> getSavedUser() async {
    final userData = await _apiService.getUserData();
    if (userData == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (e) {
      return null;
    }
  }
}
