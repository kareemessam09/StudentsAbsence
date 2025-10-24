import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  // Test which URL to use
  final isAndroid = Platform.isAndroid;
  final baseUrl = isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';

  print('Testing login with baseUrl: $baseUrl');
  print('Platform.isAndroid: $isAndroid');

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  try {
    print('\n📡 Sending login request...');
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': 'testuser1761165345@school.com',
        'password': 'password123',
      },
    );

    print('\n✅ Response received:');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');

    // Check response structure
    final token = response.data['token'];
    final userData = response.data['data']?['user'] ?? response.data['user'];

    print('\n📋 Parsed data:');
    print('Token: ${token != null ? "✅ Present" : "❌ Missing"}');
    print('User data: ${userData != null ? "✅ Present" : "❌ Missing"}');

    if (userData != null) {
      print('User: ${userData['name']} (${userData['email']})');
      print('Role: ${userData['role']}');
    }
  } catch (e) {
    print('\n❌ Error occurred:');
    if (e is DioException) {
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
    } else {
      print('Error: $e');
    }
  }
}
