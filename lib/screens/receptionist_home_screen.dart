import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/notification_state.dart';
import '../cubits/user_cubit.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../services/class_service.dart';
import '../services/student_service.dart';
import '../config/service_locator.dart';
import '../widgets/empty_state.dart';
import '../utils/responsive.dart';

class ReceptionistHomeScreen extends StatefulWidget {
  const ReceptionistHomeScreen({super.key});

  @override
  State<ReceptionistHomeScreen> createState() => _ReceptionistHomeScreenState();
}

class _ReceptionistHomeScreenState extends State<ReceptionistHomeScreen> {
  final TextEditingController _studentCodeController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();

  final ClassService _classService = getIt<ClassService>();
  final StudentService _studentService = getIt<StudentService>();

  List<ClassModel> _classes = [];
  List<StudentModel> _students = [];
  Map<String, List<ClassModel>> _groupedClasses = {};
  List<String> _grades = [];
  String? _selectedGrade;
  String? _selectedClassId;
  String? _selectedStudentId;
  bool _isLoadingClasses = false;
  bool _isLoadingStudents = false;
  bool _isSendingNotification = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadMyNotifications();
  }

  @override
  void dispose() {
    _studentCodeController.dispose();
    _studentNameController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoadingClasses = true);
    try {
      final result = await _classService.getAllClasses();
      if (result['success'] && mounted) {
        final classes = result['classes'] as List<ClassModel>;

        // Group classes by grade (extract prefix before hyphen)
        final Map<String, List<ClassModel>> grouped = {};
        for (var classModel in classes) {
          // Extract grade from class name (e.g., "G1-A" -> "G1", "KG1-B" -> "KG1")
          final parts = classModel.name.split('-');
          final grade = parts.isNotEmpty ? parts[0].trim() : 'Other';

          if (!grouped.containsKey(grade)) {
            grouped[grade] = [];
          }
          grouped[grade]!.add(classModel);
        }

        // Sort grades naturally (KG1, KG2, G1, G2, ...)
        final grades = grouped.keys.toList()
          ..sort((a, b) {
            // Custom sorting: KG1, KG2, then G1, G2, G3, etc.
            if (a.startsWith('KG') && !b.startsWith('KG')) return -1;
            if (!a.startsWith('KG') && b.startsWith('KG')) return 1;
            return a.compareTo(b);
          });

        setState(() {
          _classes = classes;
          _groupedClasses = grouped;
          _grades = grades;

          if (_grades.isNotEmpty) {
            _selectedGrade = _grades.first;
            final firstGradeClasses = _groupedClasses[_selectedGrade]!;
            if (firstGradeClasses.isNotEmpty) {
              _selectedClassId = firstGradeClasses.first.id;
              _loadStudentsForClass(_selectedClassId!);
            }
          }

          _isLoadingClasses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingClasses = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load classes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadStudentsForClass(String classId) async {
    setState(() => _isLoadingStudents = true);
    try {
      final result = await _studentService.getStudentsByClass(classId);
      if (result['success'] && mounted) {
        setState(() {
          _students = result['students'] as List<StudentModel>;
          _selectedStudentId = _students.isNotEmpty ? _students.first.id : null;
          _isLoadingStudents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
      }
    }
  }

  Future<void> _loadMyNotifications() async {
    final cubit = context.read<NotificationCubit>();
    await cubit.loadNotifications();
  }

  Future<void> _sendNotification() async {
    if (_selectedStudentId == null || _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a student'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSendingNotification = true);

    try {
      final cubit = context.read<NotificationCubit>();

      // Get the selected student and class info
      final selectedStudent = _students.firstWhere(
        (s) => s.id == _selectedStudentId,
      );
      final selectedClass = _classes.firstWhere(
        (c) => c.id == _selectedClassId,
      );

      // Find the teacher for the selected class
      final teacherId = selectedClass.teacherId;
      if (teacherId.isEmpty) {
        throw Exception('No teacher assigned to this class');
      }

      await cubit.sendRequest(
        recipientId: teacherId,
        studentId: _selectedStudentId!,
        message:
            '${selectedStudent.nameArabic ?? selectedStudent.name} - ${selectedClass.name}',
      );

      if (mounted) {
        setState(() => _isSendingNotification = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Notification sent successfully'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Reload notifications to show the newly sent one
        await _loadMyNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingNotification = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Receptionist Panel',
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
        body: Column(
          children: [
            // Input Section
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grade Dropdown (First Level)
                  if (_isLoadingClasses)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        // Grade Selection
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedGrade,
                            isExpanded: true,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Grade',
                              labelStyle: TextStyle(fontSize: 14.sp),
                              prefixIcon: Icon(Icons.school, size: 20.r),
                              border: OutlineInputBorder(
                                borderRadius: Responsive.borderRadius(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _grades.map((String grade) {
                              return DropdownMenuItem<String>(
                                value: grade,
                                child: Text(
                                  grade,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newGrade) {
                              if (newGrade != null) {
                                setState(() {
                                  _selectedGrade = newGrade;
                                  // Auto-select first class in the grade
                                  final classesInGrade =
                                      _groupedClasses[newGrade]!;
                                  if (classesInGrade.isNotEmpty) {
                                    _selectedClassId = classesInGrade.first.id;
                                    _loadStudentsForClass(_selectedClassId!);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        Responsive.horizontalSpace(12),

                        // Section/Class Selection (Second Level)
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedClassId,
                            isExpanded: true,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Section',
                              labelStyle: TextStyle(fontSize: 14.sp),
                              prefixIcon: Icon(
                                Icons.class_outlined,
                                size: 20.r,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: Responsive.borderRadius(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _selectedGrade != null
                                ? _groupedClasses[_selectedGrade]!.map((
                                    ClassModel classModel,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: classModel.id,
                                      child: Text(
                                        classModel.name,
                                        style: TextStyle(fontSize: 14.sp),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList()
                                : [],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedClassId = newValue;
                                });
                                _loadStudentsForClass(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  Responsive.verticalSpace(16),

                  // Student Dropdown
                  if (_isLoadingStudents)
                    const Center(child: CircularProgressIndicator())
                  else if (_students.isEmpty)
                    Container(
                      padding: Responsive.padding(all: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: Responsive.borderRadius(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20.r,
                          ),
                          Responsive.horizontalSpace(12),
                          Expanded(
                            child: Text(
                              'No students in this class',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedStudentId,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Select Student',
                        labelStyle: TextStyle(fontSize: 14.sp),
                        prefixIcon: Icon(Icons.person_outline, size: 20.r),
                        border: OutlineInputBorder(
                          borderRadius: Responsive.borderRadius(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _students.map((StudentModel student) {
                        return DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(
                            student.nameArabic ?? student.name,
                            style: TextStyle(fontSize: 14.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStudentId = newValue;
                          });
                        }
                      },
                    ),
                  Responsive.verticalSpace(20),

                  // Send Notification Button
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.buttonHeight(context),
                    child: ElevatedButton.icon(
                      onPressed: _isSendingNotification
                          ? null
                          : _sendNotification,
                      icon: _isSendingNotification
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.send, size: 20.r),
                      label: Text(
                        _isSendingNotification
                            ? 'Sending...'
                            : 'Send Absence Request',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: Responsive.borderRadius(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Requests List Section
            Padding(
              padding: Responsive.padding(all: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 20.r,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  Responsive.horizontalSpace(8),
                  Text(
                    'Recent Requests',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

            // ListView of Sent Notifications with BlocBuilder
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
                            size: 48.r,
                            color: Colors.red,
                          ),
                          Responsive.verticalSpace(16),
                          Text(
                            'Error loading notifications',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          Responsive.verticalSpace(8),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is NotificationLoaded) {
                    // Get notifications sent by this receptionist (from field)
                    final user = context.read<UserCubit>().currentUser;
                    final myNotifications = state.notifications
                        .where((n) => n.from == user?.id)
                        .toList();

                    if (myNotifications.isEmpty) {
                      return const EmptyState(
                        message: 'No notifications sent yet',
                        subtitle: 'Send your first absence request above',
                        icon: Icons.inbox_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: Responsive.padding(horizontal: 20),
                      itemCount: myNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = myNotifications[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          child: Card(
                            key: ValueKey(notification.id),
                            margin: Responsive.padding(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: notification.isResolved
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: Responsive.borderRadius(8),
                                ),
                                child: Icon(
                                  notification.isResolved
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: notification.isResolved
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 24.r,
                                ),
                              ),
                              title: Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Responsive.verticalSpace(4),
                                  Text(
                                    notification.isResolved
                                        ? notification.isPresent
                                              ? 'Marked as Present'
                                              : 'Marked as Absent'
                                        : 'Waiting for response',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: notification.isResolved
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  Responsive.verticalSpace(4),
                                  Text(
                                    _formatDate(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: notification.isResolved
                                  ? null
                                  : Icon(
                                      Icons.access_time,
                                      color: Colors.orange,
                                      size: 20.r,
                                    ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
