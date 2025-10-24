import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cubits/user_cubit.dart';
import '../models/class_model.dart';
import '../services/statistics_service.dart';
import '../config/service_locator.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final StatisticsService _statisticsService = getIt<StatisticsService>();

  List<ClassModel> _classes = [];
  Map<String, List<ClassModel>> _groupedClasses = {};
  List<String> _grades = [];
  Map<String, dynamic>? _overviewStats;
  List<dynamic> _attendanceData = [];
  bool _isLoadingStats = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadClassStatistics();

    // Auto-refresh stats every 60 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        _loadClassStatistics();
      }
    });
  }

  @override
  void dispose() {
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
      // Fetch daily attendance statistics from backend
      final statsResult = await _statisticsService.getDailyAttendance();

      if (statsResult['success']) {
        final data = statsResult['data'];

        if (mounted) {
          // Extract classes from attendance data
          final classesData = data['classes'] as List;

          // Group classes by grade
          final Map<String, List<ClassModel>> grouped = {};
          final List<ClassModel> classes = [];

          for (var classData in classesData) {
            // Create ClassModel from attendance data
            final classModel = ClassModel(
              id: classData['classId'] as String,
              name: classData['className'] as String,
              description: '',
              teacherId: classData['teacher']?['id'] ?? '',
              teacherName: classData['teacher']?['name'],
              studentIds: [],
              capacity: (classData['total'] ?? 0) as int,
              isActive: true,
              startDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            classes.add(classModel);

            // Group by grade
            final parts = classModel.name.split('-');
            final grade = parts.isNotEmpty ? parts[0].trim() : 'Other';

            if (!grouped.containsKey(grade)) {
              grouped[grade] = [];
            }
            grouped[grade]!.add(classModel);
          }

          // Sort grades: KG first, then G grades
          final grades = grouped.keys.toList();
          grades.sort((a, b) {
            if (a.startsWith('KG') && !b.startsWith('KG')) return -1;
            if (!a.startsWith('KG') && b.startsWith('KG')) return 1;
            return a.compareTo(b);
          });

          setState(() {
            _overviewStats = data['overall'];
            _attendanceData = classesData;
            _classes = classes;
            _groupedClasses = grouped;
            _grades = grades;
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                statsResult['message'] ?? 'Failed to load statistics';
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Manager Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1565C0),
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
        body: RefreshIndicator(
          onRefresh: _loadClassStatistics,
          child: _isLoadingStats && _classes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
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
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
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
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.chartLine,
                                  color: Color(0xFF1565C0),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ${user?.name ?? "Manager"}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'School Overview',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
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

                      // Class Cards Grouped by Grade
                      if (_classes.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No classes found'),
                          ),
                        )
                      else
                        ..._grades.map((grade) {
                          final gradeClasses = _groupedClasses[grade]!;
                          return FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Grade Header
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primaryContainer,
                                        theme.colorScheme.secondaryContainer,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.school,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        grade,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${gradeClasses.length} ${gradeClasses.length == 1 ? 'class' : 'classes'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Classes in this grade
                                ...gradeClasses.map((classModel) {
                                  // Find attendance data for this class
                                  final attendanceInfo = _attendanceData
                                      .firstWhere(
                                        (data) =>
                                            data['classId'] == classModel.id,
                                        orElse: () => null,
                                      );
                                  return _buildClassCard(
                                    theme,
                                    classModel,
                                    attendanceInfo,
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(ThemeData theme) {
    // Get data from daily attendance statistics
    final int totalClasses = _overviewStats?['totalClasses'] ?? 0;
    final int totalStudents = _overviewStats?['total'] ?? 0;
    final int totalPresent = _overviewStats?['present'] ?? 0;
    final int totalGone = _overviewStats?['gone'] ?? 0;
    final double attendanceRate = (_overviewStats?['percentage'] ?? 0)
        .toDouble();

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
                  value: totalClasses.toString(),
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
                  label: 'Gone Today',
                  value: totalGone.toString(),
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
                  icon: FontAwesomeIcons.chartLine,
                  label: 'Total Gone',
                  value: totalGone.toString(),
                  color: Colors.orange,
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
    Map<String, dynamic>? attendanceInfo,
  ) {
    // Get attendance data with new field names
    final int totalStudents = attendanceInfo?['total'] ?? classModel.capacity;
    final int presentCount = attendanceInfo?['present'] ?? 0;
    final int goneCount = attendanceInfo?['gone'] ?? 0;
    final double attendanceRate = (attendanceInfo?['percentage'] ?? 0)
        .toDouble();

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
                          classModel.teacherName ??
                              (classModel.teacherId.isEmpty
                                  ? 'No teacher assigned'
                                  : 'Teacher ID: ${classModel.teacherId}'),
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
                      value: totalStudents.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.circleCheck,
                      label: 'Present',
                      value: presentCount.toString(),
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.userXmark,
                      label: 'Gone',
                      value: goneCount.toString(),
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: FontAwesomeIcons.percent,
                      label: 'Rate',
                      value: '${attendanceRate.toStringAsFixed(0)}%',
                      color: statusColor,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
