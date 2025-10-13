import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/request_cubit.dart';
import '../cubits/request_state.dart';
import '../cubits/user_cubit.dart';
import '../widgets/request_card.dart';
import '../widgets/empty_state.dart';
import '../utils/responsive.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  void _updateRequestStatus(
    BuildContext context,
    String id,
    String status,
    String studentName,
  ) {
    context.read<RequestCubit>().updateRequestStatus(id: id, status: status);

    final statusText = status == 'Accepted'
        ? 'marked as present'
        : 'marked as not found';
    final color = status == 'Accepted' ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              status == 'Accepted' ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('$studentName $statusText')),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Panel'),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            BlocBuilder<RequestCubit, RequestState>(
              builder: (context, state) {
                if (state is RequestLoaded) {
                  final pendingCount = context
                      .read<RequestCubit>()
                      .getPendingRequests()
                      .length;

                  if (pendingCount > 0) {
                    return Center(
                      child: FadeIn(
                        child: Container(
                          margin: EdgeInsets.only(right: 16.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: Responsive.borderRadius(20),
                          ),
                          child: Text(
                            '$pendingCount pending',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Header Section
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: Responsive.padding(all: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 24.r,
                      color: theme.colorScheme.primary,
                    ),
                    Responsive.horizontalSpace(12),
                    Expanded(
                      child: Text(
                        'Pending Attendance Requests',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Requests List with BlocBuilder
            Expanded(
              child: BlocBuilder<RequestCubit, RequestState>(
                builder: (context, state) {
                  if (state is RequestLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RequestError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is RequestLoaded) {
                    final pendingRequests = context
                        .read<RequestCubit>()
                        .getPendingRequests();

                    if (pendingRequests.isEmpty) {
                      return const EmptyState(
                        message: 'No pending requests',
                        subtitle: 'All attendance requests have been processed',
                        icon: Icons.check_circle_outline,
                      );
                    }

                    return ListView.builder(
                      padding: Responsive.padding(all: 20),
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        final request = pendingRequests[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: RequestCard(
                            key: ValueKey(request.id),
                            request: request,
                            showActions: true,
                            isAnimated: true,
                            onAccept: () => _updateRequestStatus(
                              context,
                              request.id,
                              'Accepted',
                              request.studentName,
                            ),
                            onNotFound: () => _updateRequestStatus(
                              context,
                              request.id,
                              'Not Found',
                              request.studentName,
                            ),
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
    );
  }
}
