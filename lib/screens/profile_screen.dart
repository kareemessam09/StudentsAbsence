import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/user_cubit.dart';
import '../cubits/user_state.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';
import '../config/service_locator.dart';
import '../utils/responsive.dart';
import '../utils/app_logger.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Class management for teachers
  final ClassService _classService = getIt<ClassService>();
  List<ClassModel> _availableClasses = [];
  Map<String, List<ClassModel>> _groupedClasses = {};
  List<String> _grades = [];
  Set<String> _expandedGrades = {}; // Track which grades are expanded
  Set<String> _selectedClassIds = {};
  bool _handlesAllClasses = false;
  bool _isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<UserCubit>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;

      // Load classes if user is a teacher
      if (user.isTeacher) {
        _fetchAvailableClasses();
      }
    }
  }

  Future<void> _fetchAvailableClasses() async {
    AppLogger.info('Starting to fetch classes...', tag: 'ProfileScreen');
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      AppLogger.network(
        'Calling ClassService.getAllClasses()',
        tag: 'ProfileScreen',
      );
      final result = await _classService.getAllClasses(
        limit: 1000, // Fetch all classes without pagination
      );
      AppLogger.info(
        'Got result: ${result['success']} - ${result['message'] ?? 'No message'}',
        tag: 'ProfileScreen',
      );

      if (result['success']) {
        final classes = result['classes'] as List<ClassModel>;
        AppLogger.success(
          'Successfully fetched ${classes.length} classes',
          tag: 'ProfileScreen',
        );
        final user = context.read<UserCubit>().currentUser;

        // Group classes by grade
        final Map<String, List<ClassModel>> grouped = {};
        for (var classModel in classes) {
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
          _availableClasses = classes;
          _groupedClasses = grouped;
          _grades = grades;
          // Pre-select classes where this teacher is assigned
          if (user != null) {
            _selectedClassIds = classes
                .where((c) => c.teacherId == user.id)
                .map((c) => c.id)
                .toSet();
            AppLogger.info(
              'Pre-selected ${_selectedClassIds.length} classes for teacher ${user.id}',
              tag: 'ProfileScreen',
            );
          }
          _isLoadingClasses = false;
        });
      } else {
        // Handle unsuccessful response
        AppLogger.error(
          'Failed to fetch classes: ${result['message']}',
          tag: 'ProfileScreen',
        );
        setState(() {
          _isLoadingClasses = false;
        });

        if (mounted) {
          final errorMessage = result['message'] ?? 'Failed to load classes';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error(
        'Exception fetching classes',
        tag: 'ProfileScreen',
        error: e,
      );
      setState(() {
        _isLoadingClasses = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load classes: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateTeacherClasses() async {
    final user = context.read<UserCubit>().currentUser;
    if (user == null || !user.isTeacher) return;

    try {
      int successCount = 0;
      int failCount = 0;

      // Update each class using the new assign-teacher endpoint
      for (final classModel in _availableClasses) {
        final shouldAssign = _selectedClassIds.contains(classModel.id);
        final isCurrentlyAssigned = classModel.teacherId == user.id;

        if (shouldAssign && !isCurrentlyAssigned) {
          // Assign this teacher to the class
          final result = await _classService.assignTeacher(
            classId: classModel.id,
            assign: true,
          );

          if (result['success'] == true) {
            successCount++;
            debugPrint('✓ Assigned to class: ${classModel.name}');
          } else {
            failCount++;
            debugPrint(
              '✗ Failed to assign to class: ${classModel.name} - ${result['message']}',
            );
          }
        } else if (!shouldAssign && isCurrentlyAssigned) {
          // Unassign this teacher from the class
          final result = await _classService.assignTeacher(
            classId: classModel.id,
            assign: false,
          );

          if (result['success'] == true) {
            successCount++;
            debugPrint('✓ Unassigned from class: ${classModel.name}');
          } else {
            failCount++;
            debugPrint(
              '✗ Failed to unassign from class: ${classModel.name} - ${result['message']}',
            );
          }
        }
      }

      if (mounted) {
        if (failCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated $successCount classes, $failCount failed'),
              backgroundColor: failCount > successCount
                  ? Colors.red
                  : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (successCount > 0) {
          debugPrint('✓ All $successCount class updates successful');
        }
      }

      return;
    } catch (e) {
      debugPrint('✗ Error updating teacher classes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update classes: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(UserModel currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<UserCubit>();

    // Update profile info (name, email)
    if (_nameController.text.trim() != currentUser.name ||
        _emailController.text.trim() != currentUser.email) {
      await cubit.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
    }

    // Update teacher's class assignments
    if (currentUser.isTeacher) {
      await _updateTeacherClasses();
    }

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile updated successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UserError) {
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
            'Profile Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1565C0),
          elevation: 0,
        ),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final currentUser = context.read<UserCubit>().currentUser;
            final isLoading = state is UserLoading;

            if (currentUser == null) {
              return const Center(child: Text('Please log in to view profile'));
            }

            return Responsive.centerContent(
              context: context,
              child: SingleChildScrollView(
                padding: Responsive.padding(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Avatar with User Initial
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 120.r,
                                height: 120.r,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF42A5F5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1565C0,
                                      ).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    currentUser.name.isNotEmpty
                                        ? currentUser.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Responsive.verticalSpace(12),
                              Text(
                                currentUser.name,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Responsive.verticalSpace(8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentUser.isReceptionist
                                      ? 'Receptionist'
                                      : currentUser.isTeacher
                                      ? 'Teacher'
                                      : 'Manager',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Responsive.verticalSpace(32),

                      // Name Field
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: TextFormField(
                          controller: _nameController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(fontSize: 14.sp),
                            prefixIcon: Icon(Icons.person_outline, size: 20.r),
                            border: OutlineInputBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Email Field
                      FadeInRight(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(fontSize: 14.sp),
                            prefixIcon: Icon(Icons.email_outlined, size: 20.r),
                            border: OutlineInputBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Class Selection for Teachers
                      if (currentUser.isTeacher)
                        FadeIn(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Classes to Manage',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Responsive.verticalSpace(8),
                              Text(
                                'Choose which classes you want to manage attendance for',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              Responsive.verticalSpace(16),

                              // "Handle All Classes" option
                              Card(
                                elevation: Responsive.cardElevation(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: Responsive.borderRadius(12),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    'Handle All Classes',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Manage attendance for all classes in the school',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  value: _handlesAllClasses,
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _handlesAllClasses = value ?? false;
                                            if (_handlesAllClasses) {
                                              // Select all classes
                                              _selectedClassIds =
                                                  _availableClasses
                                                      .map((c) => c.id)
                                                      .toSet();
                                            }
                                          });
                                        },
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ),
                              Responsive.verticalSpace(16),

                              // Classes List
                              if (_isLoadingClasses)
                                Center(
                                  child: Padding(
                                    padding: Responsive.padding(vertical: 20),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              else if (_availableClasses.isEmpty)
                                Card(
                                  elevation: Responsive.cardElevation(context),
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: Responsive.borderRadius(12),
                                  ),
                                  child: Padding(
                                    padding: Responsive.padding(all: 20),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 32.r,
                                          color: theme.colorScheme.primary,
                                        ),
                                        Responsive.verticalSpace(12),
                                        Text(
                                          'No Classes Available',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Responsive.verticalSpace(8),
                                        Text(
                                          'Contact your administrator to create classes',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 12.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: _grades.map((grade) {
                                    final gradeClasses =
                                        _groupedClasses[grade]!;
                                    final isExpanded = _expandedGrades.contains(
                                      grade,
                                    );

                                    return Card(
                                      elevation: Responsive.cardElevation(
                                        context,
                                      ),
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: Responsive.borderRadius(
                                          12,
                                        ),
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          initiallyExpanded: isExpanded,
                                          onExpansionChanged: (expanded) {
                                            setState(() {
                                              if (expanded) {
                                                _expandedGrades.add(grade);
                                              } else {
                                                _expandedGrades.remove(grade);
                                              }
                                            });
                                          },
                                          leading: Container(
                                            padding: EdgeInsets.all(8.r),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  Responsive.borderRadius(8),
                                            ),
                                            child: Icon(
                                              Icons.school_outlined,
                                              size: 20.r,
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Text(
                                                grade,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                              Responsive.horizontalSpace(8),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  borderRadius:
                                                      Responsive.borderRadius(
                                                        10,
                                                      ),
                                                ),
                                                child: Text(
                                                  '${gradeClasses.length} ${gradeClasses.length == 1 ? 'class' : 'classes'}',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: gradeClasses.map((
                                            classModel,
                                          ) {
                                            return CheckboxListTile(
                                              title: Text(
                                                classModel.name,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                classModel.description,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              secondary: Container(
                                                padding: EdgeInsets.all(8.r),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .secondaryContainer,
                                                  borderRadius:
                                                      Responsive.borderRadius(
                                                        8,
                                                      ),
                                                ),
                                                child: Icon(
                                                  Icons.class_outlined,
                                                  size: 20.r,
                                                  color: theme
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                              ),
                                              value: _selectedClassIds.contains(
                                                classModel.id,
                                              ),
                                              onChanged:
                                                  isLoading ||
                                                      _handlesAllClasses
                                                  ? null
                                                  : (selected) {
                                                      setState(() {
                                                        if (selected == true) {
                                                          _selectedClassIds.add(
                                                            classModel.id,
                                                          );
                                                        } else {
                                                          _selectedClassIds
                                                              .remove(
                                                                classModel.id,
                                                              );
                                                        }
                                                      });
                                                    },
                                              activeColor:
                                                  theme.colorScheme.primary,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              Responsive.verticalSpace(16),
                            ],
                          ),
                        ),

                      // Info Card for Teachers
                      if (currentUser.isTeacher)
                        FadeIn(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: Responsive.cardElevation(context),
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                            child: Padding(
                              padding: Responsive.padding(all: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20.r,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Responsive.horizontalSpace(12),
                                  Expanded(
                                    child: Text(
                                      'You will only see attendance requests for your selected classes.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      Responsive.verticalSpace(32),

                      // Save Button with Gradient
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: Container(
                          height: Responsive.buttonHeight(context),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: Responsive.borderRadius(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _saveProfile(currentUser),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: Responsive.borderRadius(12),
                              ),
                            ),
                            icon: isLoading
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.save,
                                    size: 20.r,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              isLoading ? 'Saving...' : 'Save Changes',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Logout Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: Container(
                          height: Responsive.buttonHeight(context),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE53935),
                              width: 2,
                            ),
                            borderRadius: Responsive.borderRadius(12),
                          ),
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'Logout',
                                          style: TextStyle(fontSize: 18.sp),
                                        ),
                                        content: Text(
                                          'Are you sure you want to logout?',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              context
                                                  .read<UserCubit>()
                                                  .logout();
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/login',
                                                (route) => false,
                                              );
                                            },
                                            child: Text(
                                              'Logout',
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              foregroundColor: const Color(0xFFE53935),
                              shape: RoundedRectangleBorder(
                                borderRadius: Responsive.borderRadius(12),
                              ),
                            ),
                            icon: Icon(
                              Icons.logout,
                              size: 20.r,
                              color: const Color(0xFFE53935),
                            ),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
