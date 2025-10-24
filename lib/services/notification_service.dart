import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

/// Notification Service
/// Handles all notification related API calls
class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  /// Get all notifications for current user
  /// GET /notifications
  Future<Map<String, dynamic>> getAllNotifications({
    String? status,
    String? type,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _apiService.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      // Handle nested data structure (response might have 'data' wrapper)
      final responseData =
          response.data is Map<String, dynamic> &&
              response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      debugPrint(
        'Notification response structure: ${responseData?.runtimeType}',
      );
      debugPrint(
        'Response keys: ${responseData is Map ? responseData.keys.toList() : "Not a map"}',
      );

      // Try to find notifications in the response
      final notificationsList = responseData is Map<String, dynamic>
          ? (responseData['notifications'] ?? responseData['data'])
          : null;

      if (notificationsList == null) {
        debugPrint(
          'No notifications found in response. Response data: $responseData',
        );
        return {
          'success': false,
          'message': 'Invalid response format: notifications not found',
          'notifications': <NotificationModel>[],
        };
      }

      if (notificationsList is! List) {
        debugPrint(
          'Notifications is not a list. Type: ${notificationsList.runtimeType}',
        );
        return {
          'success': false,
          'message': 'Invalid response format: notifications is not a list',
          'notifications': <NotificationModel>[],
        };
      }

      final notifications = notificationsList
          .map((json) {
            try {
              return NotificationModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing notification: $e');
              debugPrint('Problem JSON: $json');
              return null;
            }
          })
          .whereType<NotificationModel>()
          .toList();

      debugPrint('Successfully parsed ${notifications.length} notifications');

      return {
        'success': true,
        'notifications': notifications,
        'total': responseData['total'] ?? notifications.length,
        'page': responseData['page'] ?? page,
        'totalPages': responseData['totalPages'] ?? 1,
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'notifications': <NotificationModel>[],
      };
    }
  }

  /// Send a request notification
  /// POST /notifications/request
  Future<Map<String, dynamic>> sendRequest({
    required String recipientId,
    required String studentId,
    required String message,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.sendNotification,
        data: {
          'recipientId': recipientId,
          'studentId': studentId,
          'message': message,
        },
      );

      final notification = NotificationModel.fromJson(response.data);

      return {
        'success': true,
        'notification': notification,
        'message': 'Request sent successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Respond to a notification
  /// POST /notifications/:id/respond
  Future<Map<String, dynamic>> respondToNotification({
    required String notificationId,
    required bool approved,
    String? responseMessage,
  }) async {
    try {
      debugPrint(
        'Responding to notification: $notificationId, approved: $approved',
      );

      final response = await _apiService.post(
        ApiEndpoints.respondToNotification(notificationId),
        data: {
          'approved': approved,
          if (responseMessage != null) 'responseMessage': responseMessage,
        },
      );

      debugPrint('Response data type: ${response.data.runtimeType}');
      debugPrint('Response data: ${response.data}');

      // Handle nested response structure if present
      final notificationData =
          response.data is Map && response.data.containsKey('data')
          ? response.data['data']['notification'] ?? response.data['data']
          : response.data;

      final notification = NotificationModel.fromJson(notificationData);

      return {
        'success': true,
        'notification': notification,
        'message': approved ? 'Request approved' : 'Request rejected',
      };
    } catch (e, stackTrace) {
      debugPrint('Error in respondToNotification: $e');
      debugPrint('Stack trace: $stackTrace');
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Mark notification as read
  /// PATCH /notifications/:id/read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.markAsRead(notificationId),
      );

      final notification = NotificationModel.fromJson(response.data);

      return {'success': true, 'notification': notification};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Mark all notifications as read
  /// PATCH /notifications/read-all
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiService.patch(ApiEndpoints.markAllAsRead);

      return {
        'success': true,
        'message':
            response.data['message'] ?? 'All notifications marked as read',
        'count': response.data['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Delete notification
  /// DELETE /notifications/:id
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete(ApiEndpoints.deleteNotification(notificationId));

      return {'success': true, 'message': 'Notification deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get unread notifications count
  /// GET /notifications/unread/count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _apiService.get(ApiEndpoints.unreadCount);

      return {'success': true, 'count': response.data['count'] ?? 0};
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'count': 0,
      };
    }
  }

  /// Get sent notifications (for managers)
  /// GET /notifications/sent
  Future<Map<String, dynamic>> getSentNotifications({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.sentNotifications,
        queryParameters: {'page': page, 'limit': limit},
      );

      final notifications = (response.data['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      return {
        'success': true,
        'notifications': notifications,
        'total': response.data['total'] ?? notifications.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'notifications': <NotificationModel>[],
      };
    }
  }
}
