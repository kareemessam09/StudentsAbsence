import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/notification_state.dart';
import '../cubits/user_cubit.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';
import '../config/service_locator.dart';

class DeanHomeScreen extends StatefulWidget {
  const DeanHomeScreen({super.key});

  @override
  State<DeanHomeScreen> createState() => _DeanHomeScreenState();
}

class _DeanHomeScreenState extends State<DeanHomeScreen>
    with SingleTickerProviderStateMixin {
  final ClassService _classService = getIt<ClassService>();
  late TabController _tabController;

  List<ClassModel> _classes = [];
  Map<String, Map<String, dynamic>> _classStats = {};
  bool _isLoadingStats = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClassStatistics();

    // Auto-refresh stats every 60 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted && _tabController.index == 0) {
        _loadClassStatistics();
      }
    });

    // Load notifications
    Future.microtask(() {
      context.read<NotificationCubit>().loadPendingNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadClassStatistics() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStats = true;
      _errorMessage = null;
    });

    try {
      // Fetch all classes
      final classesResult = await _classService.getAllClasses();

      if (classesResult['success']) {
        final classes = (classesResult['classes'] as List)
            .map(
              (json) => json is ClassModel ? json : ClassModel.fromJson(json),
            )
            .toList();

        // Fetch stats for each class
        final Map<String, Map<String, dynamic>> stats = {};

        for (var classModel in classes) {
          try {
            final statsResult = await _classService.getClassStats(
              classModel.id,
            );
            if (statsResult['success']) {
              stats[classModel.id] = statsResult['stats'];
            }
          } catch (e) {
            debugPrint('Error loading stats for class ${classModel.id}: $e');
          }
        }

        if (mounted) {
          setState(() {
            _classes = classes;
            _classStats = stats;
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                classesResult['message'] ?? 'Failed to load classes';
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoadingStats = false;
        });
      }
    }
  }

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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Statistics'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Statistics Tab
            _buildStatisticsTab(theme, user),

            // Notifications Tab
            _buildNotificationsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(ThemeData theme, dynamic user) {
    return RefreshIndicator(
      onRefresh: _loadClassStatistics,
      child: _isLoadingStats && _classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadClassStatistics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'School Overview',
                                  style: theme.textTheme.bodyMedium?.copyWith(
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

                  // Calculate overall stats
                  _buildOverallStats(theme),

                  const SizedBox(height: 32),

                  // Class List
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Class Statistics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Class Cards
                  if (_classes.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No classes found'),
                      ),
                    )
                  else
                    ..._classes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final classModel = entry.value;
                      final stats = _classStats[classModel.id];

                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 500 + (index * 100)),
                        child: _buildClassCard(theme, classModel, stats),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallStats(ThemeData theme) {
    int totalStudents = 0;
    int totalAbsent = 0;
    int totalPresent = 0;
    int totalCapacity = 0;

    for (var classModel in _classes) {
      totalStudents += classModel.studentCount;
      totalCapacity += classModel.capacity;

      final stats = _classStats[classModel.id];
      if (stats != null) {
        totalAbsent += (stats['absentToday'] as int?) ?? 0;
        totalPresent += (stats['presentToday'] as int?) ?? 0;
      }
    }

    final double attendanceRate = totalStudents > 0
        ? (totalPresent / totalStudents) * 100
        : 0.0;

    return Column(
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: FontAwesomeIcons.school,
                  label: 'Total Classes',
                  value: _classes.length.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: FontAwesomeIcons.users,
                  label: 'Total Students',
                  value: totalStudents.toString(),
                  color: Colors.purple,
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
                  label: 'Present Today',
                  value: totalPresent.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: FontAwesomeIcons.userXmark,
                  label: 'Absent Today',
                  value: totalAbsent.toString(),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: FontAwesomeIcons.percent,
                  label: 'Attendance Rate',
                  value: '${attendanceRate.toStringAsFixed(1)}%',
                  color: attendanceRate >= 80
                      ? Colors.green
                      : attendanceRate >= 60
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: FontAwesomeIcons.chartPie,
                  label: 'Capacity Used',
                  value: totalCapacity > 0
                      ? '${((totalStudents / totalCapacity) * 100).toStringAsFixed(0)}%'
                      : '0%',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(
    ThemeData theme,
    ClassModel classModel,
    Map<String, dynamic>? stats,
  ) {
    final int absentToday = stats?['absentToday'] ?? 0;
    final int presentToday = stats?['presentToday'] ?? 0;
    final double attendanceRate = stats?['attendanceRate']?.toDouble() ?? 0.0;

    final Color statusColor = attendanceRate >= 80
        ? Colors.green
        : attendanceRate >= 60
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to class details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      FontAwesomeIcons.chalkboardUser,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Teacher ID: ${classModel.teacherId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${attendanceRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.users,
                      label: 'Total',
                      value: classModel.studentCount.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.circleCheck,
                      label: 'Present',
                      value: presentToday.toString(),
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.userXmark,
                      label: 'Absent',
                      value: absentToday.toString(),
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.doorOpen,
                      label: 'Available',
                      value: classModel.availableSpots.toString(),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildNotificationsTab(ThemeData theme) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<NotificationCubit>()
                        .loadPendingNotifications();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is NotificationLoaded) {
          final notifications = state.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.bellSlash,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationCubit>().loadPendingNotifications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: Duration(milliseconds: index * 50),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          notification.status,
                        ).withOpacity(0.2),
                        child: Icon(
                          _getStatusIcon(notification.status),
                          color: _getStatusColor(notification.status),
                        ),
                      ),
                      title: Text(notification.message),
                      subtitle: Text(
                        'From: ${notification.from}\n'
                        'Student ID: ${notification.studentId}',
                      ),
                      trailing: _buildStatusBadge(notification.status),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'rejected':
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FontAwesomeIcons.clock;
      case 'approved':
      case 'accepted':
        return FontAwesomeIcons.circleCheck;
      case 'rejected':
      case 'declined':
        return FontAwesomeIcons.circleXmark;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Stat Card Widget
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
