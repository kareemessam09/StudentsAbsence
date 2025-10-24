import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/api_config.dart';

/// Base API Service
/// Handles all HTTP requests with authentication and error handling
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());

    // Add logger in debug mode
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Auth Interceptor - Adds JWT token to requests
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from secure storage
        final token = await _storage.read(key: ApiConfig.tokenKey);

        // Add token to headers if it exists
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
    );
  }

  /// Error Interceptor - Handles common errors
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid - clear storage
          await _storage.delete(key: ApiConfig.tokenKey);
          await _storage.delete(key: ApiConfig.userKey);

          // You can emit an event here to logout the user
          // or navigate to login screen
        }

        return handler.next(error);
      },
    );
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConfig.tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: ApiConfig.tokenKey);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    await _storage.delete(key: ApiConfig.tokenKey);
    await _storage.delete(key: ApiConfig.userKey);
  }

  /// Save user data
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: ApiConfig.userKey, value: userData);
  }

  /// Get user data
  Future<String?> getUserData() async {
    return await _storage.read(key: ApiConfig.userKey);
  }

  // ============================================================================
  // HTTP Methods
  // ============================================================================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // Error Handling
  // ============================================================================

  /// Extract error message from DioException
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          // Try to get message from different possible locations in response
          final message =
              error.response?.data?['message'] ??
              error.response?.data?['error'] ??
              error.response?.statusMessage;

          if (statusCode == 401) {
            return message ?? 'Unauthorized. Please login again.';
          } else if (statusCode == 403) {
            return message ??
                'You don\'t have permission to perform this action.';
          } else if (statusCode == 404) {
            return message ?? 'Resource not found.';
          } else if (statusCode == 429) {
            // Rate limiting error
            return message ?? 'Too many requests. Please try again later.';
          } else if (statusCode == 500) {
            return message ?? 'Server error. Please try again later.';
          }

          return message ?? 'Something went wrong. Please try again.';

        case DioExceptionType.cancel:
          return 'Request cancelled.';

        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') ?? false) {
            return 'No internet connection.';
          }
          return 'An unexpected error occurred.';

        default:
          return 'An unexpected error occurred.';
      }
    }

    return error.toString();
  }
}
