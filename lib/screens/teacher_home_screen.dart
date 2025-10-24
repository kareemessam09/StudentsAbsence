import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/notification_state.dart';
import '../cubits/user_cubit.dart';
import '../cubits/user_state.dart';
import '../models/notification_model.dart';
import '../widgets/empty_state.dart';
import '../utils/responsive.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications immediately
    Future.microtask(() {
      context.read<NotificationCubit>().loadPendingNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    await context.read<NotificationCubit>().loadPendingNotifications();
  }

  Future<void> _respondToNotification({
    required String notificationId,
    required bool approved,
    required String studentName,
  }) async {
    final responseMessage = approved
        ? 'Student was present in class'
        : 'Student was not found in class';

    await context.read<NotificationCubit>().respondToNotification(
      notificationId: notificationId,
      approved: approved,
      responseMessage: responseMessage,
    );

    if (mounted) {
      final statusText = approved ? 'approved' : 'rejected';
      final color = approved ? Colors.green : Colors.orange;
      final icon = approved ? Icons.check_circle : Icons.cancel;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Request $statusText for $studentName')),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: BlocListener<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text(
              'Teacher Panel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1565C0),
            automaticallyImplyLeading: false,
            actions: [
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoaded && state.pendingCount > 0) {
                    return Center(
                      child: FadeIn(
                        child: Container(
                          margin: EdgeInsets.only(right: 16.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFB8C00),
                            borderRadius: Responsive.borderRadius(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFB8C00).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${state.pendingCount} pending',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'Profile',
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: Column(
              children: [
                BlocBuilder<UserCubit, UserState>(
                  builder: (context, userState) {
                    final userName =
                        context.read<UserCubit>().currentUser?.name ??
                        'Teacher';
                    return FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: Responsive.padding(all: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1565C0).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: Responsive.borderRadius(12),
                              ),
                              child: Icon(
                                Icons.pending_actions,
                                size: 24.r,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                            Responsive.horizontalSpace(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, $userName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Attendance Requests',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is NotificationError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64.r,
                                color: Colors.red,
                              ),
                              Responsive.verticalSpace(16),
                              Text(
                                'Error loading notifications',
                                style: theme.textTheme.titleMedium,
                              ),
                              Responsive.verticalSpace(8),
                              Padding(
                                padding: Responsive.padding(horizontal: 24),
                                child: Text(
                                  state.message,
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Responsive.verticalSpace(16),
                              ElevatedButton.icon(
                                onPressed: _refreshNotifications,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is NotificationLoaded) {
                        final pendingNotifications = state.pendingNotifications;

                        if (pendingNotifications.isEmpty) {
                          return const EmptyState(
                            message: 'No pending requests',
                            subtitle:
                                'All attendance requests have been processed',
                            icon: Icons.check_circle_outline,
                          );
                        }
                        return ListView.builder(
                          padding: Responsive.padding(all: 16),
                          itemCount: pendingNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = pendingNotifications[index];
                            return FadeInUp(
                              duration: Duration(
                                milliseconds: 300 + (index * 100),
                              ),
                              child: _NotificationCard(
                                key: ValueKey(notification.id),
                                notification: notification,
                                onApprove: () => _respondToNotification(
                                  notificationId: notification.id,
                                  approved: true,
                                  studentName:
                                      notification.studentNameArabic ??
                                      notification.studentName ??
                                      notification.studentId,
                                ),
                                onReject: () => _respondToNotification(
                                  notificationId: notification.id,
                                  approved: false,
                                  studentName:
                                      notification.studentNameArabic ??
                                      notification.studentName ??
                                      notification.studentId,
                                ),
                                formatTimeAgo: _formatTimeAgo,
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String Function(DateTime) formatTimeAgo;

  const _NotificationCard({
    super.key,
    required this.notification,
    required this.onApprove,
    required this.onReject,
    required this.formatTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = formatTimeAgo(notification.createdAt);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: Responsive.borderRadius(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: Responsive.padding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: Responsive.borderRadius(8),
                  ),
                  child: Text(
                    notification.type.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Responsive.horizontalSpace(8),
                if (!notification.isRead)
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 14.r,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                Responsive.horizontalSpace(4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            Responsive.verticalSpace(12),
            Container(
              padding: Responsive.padding(all: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: Responsive.borderRadius(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 20.r,
                    color: theme.colorScheme.primary,
                  ),
                  Responsive.horizontalSpace(12),
                  Expanded(
                    child: Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Responsive.verticalSpace(16),
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final isLoading =
                    state is NotificationActionLoading &&
                    state.notificationId == notification.id;
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: Responsive.borderRadius(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF43A047).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          icon: isLoading
                              ? SizedBox(
                                  width: 16.r,
                                  height: 16.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.check_circle, size: 20.r),
                          label: Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Responsive.horizontalSpace(12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFFB8C00),
                            width: 2,
                          ),
                          borderRadius: Responsive.borderRadius(12),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFB8C00),
                            side: BorderSide.none,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          icon: Icon(Icons.cancel, size: 20.r),
                          label: Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
