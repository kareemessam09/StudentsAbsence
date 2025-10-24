import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../config/service_locator.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  // Get service from service locator
  final NotificationService _notificationService = getIt<NotificationService>();

  // Current loaded notifications for reference
  List<NotificationModel> _currentNotifications = [];

  // Load all notifications for current user
  Future<void> loadNotifications({
    String? status,
    String? type,
    int page = 1,
    int limit = 50,
  }) async {
    emit(NotificationLoading());

    try {
      final result = await _notificationService.getAllNotifications(
        status: status,
        type: type,
        page: page,
        limit: limit,
      );

      if (result['success']) {
        _currentNotifications =
            result['notifications'] as List<NotificationModel>;
        emit(
          NotificationLoaded(
            notifications: _currentNotifications,
            total: result['total'] ?? 0,
            page: result['page'] ?? 1,
            totalPages: result['totalPages'] ?? 1,
          ),
        );
      } else {
        emit(
          NotificationError(
            result['message'] ?? 'Failed to load notifications',
          ),
        );
      }
    } catch (e) {
      emit(NotificationError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Refresh notifications (reload current filter/page)
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  // Load pending notifications only
  Future<void> loadPendingNotifications() async {
    await loadNotifications(status: 'pending');
  }

  // Send a request notification
  Future<void> sendRequest({
    required String recipientId,
    required String studentId,
    required String message,
  }) async {
    final currentState = state;

    try {
      final result = await _notificationService.sendRequest(
        recipientId: recipientId,
        studentId: studentId,
        message: message,
      );

      if (result['success']) {
        emit(
          NotificationActionSuccess(
            message: result['message'] ?? 'Request sent successfully',
            notification: result['notification'],
          ),
        );

        // Reload notifications to include the new one
        await loadNotifications();
      } else {
        emit(NotificationError(result['message'] ?? 'Failed to send request'));
        // Restore previous state
        if (currentState is NotificationLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(NotificationError('Failed to send request: ${e.toString()}'));
      // Restore previous state
      if (currentState is NotificationLoaded) {
        emit(currentState);
      }
    }
  }

  // Respond to a notification (approve/reject)
  Future<void> respondToNotification({
    required String notificationId,
    required bool approved,
    String? responseMessage,
  }) async {
    final currentState = state;
    emit(
      NotificationActionLoading(
        notificationId: notificationId,
        action: 'respond',
      ),
    );

    try {
      final result = await _notificationService.respondToNotification(
        notificationId: notificationId,
        approved: approved,
        responseMessage: responseMessage,
      );

      if (result['success']) {
        emit(
          NotificationActionSuccess(
            message: result['message'] ?? 'Response sent successfully',
            notification: result['notification'],
          ),
        );

        // Update local list
        if (currentState is NotificationLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == notificationId) {
              return result['notification'] as NotificationModel;
            }
            return n;
          }).toList();

          _currentNotifications = updatedNotifications;
          emit(
            NotificationLoaded(
              notifications: updatedNotifications,
              total: currentState.total,
              page: currentState.page,
              totalPages: currentState.totalPages,
            ),
          );
        }
      } else {
        emit(NotificationError(result['message'] ?? 'Failed to respond'));
        // Restore previous state
        if (currentState is NotificationLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(NotificationError('Failed to respond: ${e.toString()}'));
      // Restore previous state
      if (currentState is NotificationLoaded) {
        emit(currentState);
      }
    }
  }

  // Approve notification (shortcut)
  Future<void> approveNotification({
    required String notificationId,
    String? responseMessage,
  }) async {
    await respondToNotification(
      notificationId: notificationId,
      approved: true,
      responseMessage: responseMessage,
    );
  }

  // Reject notification (shortcut)
  Future<void> rejectNotification({
    required String notificationId,
    String? responseMessage,
  }) async {
    await respondToNotification(
      notificationId: notificationId,
      approved: false,
      responseMessage: responseMessage,
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final currentState = state;

    try {
      final result = await _notificationService.markAsRead(notificationId);

      if (result['success']) {
        // Update local list
        if (currentState is NotificationLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == notificationId) {
              return result['notification'] as NotificationModel;
            }
            return n;
          }).toList();

          _currentNotifications = updatedNotifications;
          emit(
            NotificationLoaded(
              notifications: updatedNotifications,
              total: currentState.total,
              page: currentState.page,
              totalPages: currentState.totalPages,
            ),
          );
        }
      } else {
        // Silently fail for mark as read
        if (currentState is NotificationLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      // Silently fail for mark as read
      if (currentState is NotificationLoaded) {
        emit(currentState);
      }
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final currentState = state;

    try {
      final result = await _notificationService.markAllAsRead();

      if (result['success']) {
        // Reload notifications to get updated read status
        await loadNotifications();
      } else {
        emit(
          NotificationError(result['message'] ?? 'Failed to mark all as read'),
        );
        // Restore previous state
        if (currentState is NotificationLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(NotificationError('Failed to mark all as read: ${e.toString()}'));
      // Restore previous state
      if (currentState is NotificationLoaded) {
        emit(currentState);
      }
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final currentState = state;
    emit(
      NotificationActionLoading(
        notificationId: notificationId,
        action: 'delete',
      ),
    );

    try {
      final result = await _notificationService.deleteNotification(
        notificationId,
      );

      if (result['success']) {
        emit(
          NotificationActionSuccess(
            message: result['message'] ?? 'Notification deleted',
          ),
        );

        // Remove from local list
        if (currentState is NotificationLoaded) {
          final updatedNotifications = currentState.notifications
              .where((n) => n.id != notificationId)
              .toList();

          _currentNotifications = updatedNotifications;
          emit(
            NotificationLoaded(
              notifications: updatedNotifications,
              total: currentState.total - 1,
              page: currentState.page,
              totalPages: currentState.totalPages,
            ),
          );
        }
      } else {
        emit(NotificationError(result['message'] ?? 'Failed to delete'));
        // Restore previous state
        if (currentState is NotificationLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(NotificationError('Failed to delete: ${e.toString()}'));
      // Restore previous state
      if (currentState is NotificationLoaded) {
        emit(currentState);
      }
    }
  }

  // Get unread count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      return await _notificationService.getUnreadCount();
    } catch (e) {
      return {'success': false, 'count': 0};
    }
  }

  // Get sent notifications
  Future<void> loadSentNotifications({int page = 1, int limit = 50}) async {
    emit(NotificationLoading());

    try {
      final result = await _notificationService.getSentNotifications(
        page: page,
        limit: limit,
      );

      if (result['success']) {
        _currentNotifications =
            result['notifications'] as List<NotificationModel>;
        emit(
          NotificationLoaded(
            notifications: _currentNotifications,
            total: result['total'] ?? 0,
            page: result['page'] ?? 1,
            totalPages: result['totalPages'] ?? 1,
          ),
        );
      } else {
        emit(
          NotificationError(
            result['message'] ?? 'Failed to load sent notifications',
          ),
        );
      }
    } catch (e) {
      emit(NotificationError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Helper getters for current state data
  List<NotificationModel> get currentNotifications => _currentNotifications;

  List<NotificationModel> get pendingNotifications =>
      _currentNotifications.where((n) => n.isPending).toList();

  List<NotificationModel> get unreadNotifications =>
      _currentNotifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;
  int get pendingCount => pendingNotifications.length;
}
