import 'package:equatable/equatable.dart';
import '../models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int total;
  final int page;
  final int totalPages;

  const NotificationLoaded({
    required this.notifications,
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
  });

  @override
  List<Object?> get props => [notifications, total, page, totalPages];

  // Helper methods to filter notifications
  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get pendingNotifications =>
      notifications.where((n) => n.isPending).toList();

  List<NotificationModel> get resolvedNotifications =>
      notifications.where((n) => n.isResolved).toList();

  int get unreadCount => unreadNotifications.length;
  int get pendingCount => pendingNotifications.length;
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationActionLoading extends NotificationState {
  final String notificationId;
  final String action; // 'respond', 'read', 'delete'

  const NotificationActionLoading({
    required this.notificationId,
    required this.action,
  });

  @override
  List<Object?> get props => [notificationId, action];
}

class NotificationActionSuccess extends NotificationState {
  final String message;
  final NotificationModel? notification;

  const NotificationActionSuccess({required this.message, this.notification});

  @override
  List<Object?> get props => [message, notification];
}
