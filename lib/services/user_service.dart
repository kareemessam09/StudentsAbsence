import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// User Service
/// Handles all user related API calls
class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// Get all users (managers only)
  /// GET /users
  Future<Map<String, dynamic>> getAllUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }

      final response = await _apiService.get(
        ApiEndpoints.users,
        queryParameters: queryParams,
      );

      final users = (response.data['users'] as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      return {
        'success': true,
        'users': users,
        'total': response.data['total'] ?? users.length,
        'page': response.data['page'] ?? page,
        'totalPages': response.data['totalPages'] ?? 1,
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'users': <UserModel>[],
      };
    }
  }

  /// Get user by ID (managers only)
  /// GET /users/:id
  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.userById(id));

      final user = UserModel.fromJson(response.data);

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get current user's profile
  /// GET /users/profile/me
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.myProfile);

      final user = UserModel.fromJson(response.data);

      // Update saved user data
      await _apiService.saveUserData(jsonEncode(user.toJson()));

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Update user profile
  /// PUT /users/:id
  Future<Map<String, dynamic>> updateUser({
    required String id,
    String? name,
    String? email,
    bool? isManager,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (isManager != null) data['isManager'] = isManager;

      final response = await _apiService.put(
        ApiEndpoints.userById(id),
        data: data,
      );

      final user = UserModel.fromJson(response.data);

      return {
        'success': true,
        'user': user,
        'message': 'User updated successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Update current user's profile
  /// PUT /users/profile/me
  Future<Map<String, dynamic>> updateMyProfile({
    String? name,
    String? email,
    List<String>? assignedClasses,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (assignedClasses != null) data['assignedClasses'] = assignedClasses;

      final response = await _apiService.put(
        ApiEndpoints.updateMyProfile,
        data: data,
      );

      final user = UserModel.fromJson(response.data);

      // Update saved user data
      await _apiService.saveUserData(jsonEncode(user.toJson()));

      return {
        'success': true,
        'user': user,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Delete user (managers only)
  /// DELETE /users/:id
  Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      await _apiService.delete(ApiEndpoints.userById(id));

      return {'success': true, 'message': 'User deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}
