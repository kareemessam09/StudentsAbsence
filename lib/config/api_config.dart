import 'dart:io' show Platform;

/// API Configuration Constants
class ApiConfig {
  // Base URL - Change this for production
  // For Android Emulator use: 10.0.2.2 instead of localhost
  // For iOS Simulator use: localhost
  // For physical device use: your computer's IP address (e.g., 192.168.1.100)
  static String get baseUrl {
    // Detect if running on Android emulator
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
    } catch (e) {
      // Platform not available in web
    }
    return 'http://localhost:3000/api';
  }

  static String get socketUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      }
    } catch (e) {
      // Platform not available in web
    }
    return 'http://localhost:3000';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
}

/// API Endpoints
class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String getMe = '/auth/me'; // Renamed from 'me'
  static const String updatePassword =
      '/auth/password'; // Changed path to match backend
  static const String forgotPassword = '/auth/forgot-password';
  static String resetPassword(String token) =>
      '/auth/reset-password'; // Token passed in body, not URL

  // Users
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String myProfile = '/users/profile/me';
  static const String updateMyProfile = '/users/profile/me'; // Added for PUT

  // Students
  static const String students = '/students';
  static String studentById(String id) => '/students/$id';
  static String studentsByClass(String classId) => '/students/class/$classId';
  static const String bulkImportStudents = '/students/bulk'; // Added

  // Classes
  static const String classes = '/classes';
  static String classById(String id) => '/classes/$id';
  static String classesByTeacher(String teacherId) =>
      '/classes/teacher/$teacherId';
  static String assignTeacherToClass(String classId) =>
      '/classes/$classId/assign-teacher'; // Teacher self-assignment
  static String addStudentToClass(String classId) =>
      '/classes/$classId/students';
  static String removeStudentFromClass(String classId, String studentId) =>
      '/classes/$classId/students/$studentId';
  static String classStats(String classId) =>
      '/classes/$classId/stats'; // Added

  // Notifications
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String sendNotification =
      '/notifications/request'; // Renamed from notificationRequest
  static const String notificationMessage = '/notifications/message';
  static String respondToNotification(String id) =>
      '/notifications/$id/respond'; // Renamed
  static String markAsRead(String id) => '/notifications/$id/read'; // Renamed
  static const String markAllAsRead = '/notifications/read-all'; // Added
  static const String unreadCount = '/notifications/unread/count'; // Renamed
  static String deleteNotification(String id) => '/notifications/$id'; // Added
  static const String sentNotifications = '/notifications/sent'; // Added
  static String notificationsByStudent(String studentId) =>
      '/notifications/student/$studentId';

  // Statistics
  static const String statisticsOverview = '/statistics/overview';
}
