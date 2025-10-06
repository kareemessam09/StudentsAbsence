import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../cubits/request_cubit.dart';
import '../cubits/request_state.dart';
import '../widgets/request_card.dart';
import '../widgets/empty_state.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Panel'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
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
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pendingCount pending',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
        ],
      ),
      body: Column(
        children: [
          // Header Section
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pending Attendance Requests',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.all(20),
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
    );
  }
}
