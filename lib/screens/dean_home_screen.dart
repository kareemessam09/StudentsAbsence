import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cubits/request_cubit.dart';
import '../cubits/request_state.dart';
import '../cubits/user_cubit.dart';
import '../models/request_model.dart';

class DeanHomeScreen extends StatelessWidget {
  const DeanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<UserCubit>().currentUser;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dean Dashboard'),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        body: BlocBuilder<RequestCubit, RequestState>(
          builder: (context, state) {
            if (state is RequestLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RequestError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            if (state is RequestLoaded) {
              final allRequests = state.requests;
              final stats = _calculateStatistics(allRequests);

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<RequestCubit>().loadRequests();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.secondaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  FontAwesomeIcons.chartLine,
                                  color: theme.colorScheme.onPrimary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ${user?.name ?? "Dean"}',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Attendance Overview',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Overall Statistics
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Overall Statistics',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Overall Stats Cards
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: FontAwesomeIcons.clipboardList,
                                label: 'Total Requests',
                                value: stats.totalRequests.toString(),
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: FontAwesomeIcons.clock,
                                label: 'Pending',
                                value: stats.totalPending.toString(),
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: FontAwesomeIcons.circleCheck,
                                label: 'Accepted',
                                value: stats.totalAccepted.toString(),
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: FontAwesomeIcons.circleXmark,
                                label: 'Not Found',
                                value: stats.totalNotFound.toString(),
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Class-wise Statistics
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'Class-wise Breakdown',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Class Statistics
                      ...stats.classStats.entries.map((entry) {
                        final index = stats.classStats.keys.toList().indexOf(
                          entry.key,
                        );
                        return FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: Duration(milliseconds: 500 + (index * 100)),
                          child: _ClassStatCard(
                            className: entry.key,
                            stats: entry.value,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  DeanStatistics _calculateStatistics(List<RequestModel> requests) {
    final stats = DeanStatistics();

    stats.totalRequests = requests.length;
    stats.totalPending = requests.where((r) => r.status == 'pending').length;
    stats.totalAccepted = requests.where((r) => r.status == 'accepted').length;
    stats.totalNotFound = requests.where((r) => r.status == 'not_found').length;

    // Group by class
    final classGroups = <String, List<RequestModel>>{};
    for (var request in requests) {
      classGroups.putIfAbsent(request.className, () => []).add(request);
    }

    // Calculate per-class statistics
    for (var entry in classGroups.entries) {
      final classRequests = entry.value;
      stats.classStats[entry.key] = ClassStatistics(
        total: classRequests.length,
        pending: classRequests.where((r) => r.status == 'pending').length,
        accepted: classRequests.where((r) => r.status == 'accepted').length,
        notFound: classRequests.where((r) => r.status == 'not_found').length,
      );
    }

    return stats;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassStatCard extends StatelessWidget {
  final String className;
  final ClassStatistics stats;

  const _ClassStatCard({required this.className, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = stats.total;
    final acceptedPercent = total > 0
        ? (stats.accepted / total * 100).toInt()
        : 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        FontAwesomeIcons.chalkboardUser,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      className,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$total Total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? stats.accepted / total : 0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$acceptedPercent% Attendance Rate',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                  icon: FontAwesomeIcons.clock,
                  label: 'Pending',
                  value: stats.pending.toString(),
                  color: Colors.orange,
                ),
                _MiniStat(
                  icon: FontAwesomeIcons.circleCheck,
                  label: 'Accepted',
                  value: stats.accepted.toString(),
                  color: Colors.green,
                ),
                _MiniStat(
                  icon: FontAwesomeIcons.circleXmark,
                  label: 'Not Found',
                  value: stats.notFound.toString(),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// Data classes for statistics
class DeanStatistics {
  int totalRequests = 0;
  int totalPending = 0;
  int totalAccepted = 0;
  int totalNotFound = 0;
  Map<String, ClassStatistics> classStats = {};
}

class ClassStatistics {
  final int total;
  final int pending;
  final int accepted;
  final int notFound;

  ClassStatistics({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.notFound,
  });
}
