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
    print('🔵 Starting to fetch classes...');
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      print('🔵 Calling ClassService.getAllClasses()...');
      final result = await _classService.getAllClasses();
      print(
        '🔵 Got result: ${result['success']} - ${result['message'] ?? 'No message'}',
      );

      if (result['success']) {
        final classes = result['classes'] as List<ClassModel>;
        print('🟢 Successfully fetched ${classes.length} classes');
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
            print(
              '🟢 Pre-selected ${_selectedClassIds.length} classes for teacher ${user.id}',
            );
          }
          _isLoadingClasses = false;
        });
      } else {
        // Handle unsuccessful response
        print('🔴 Failed to fetch classes: ${result['message']}');
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
      print('🔴 Exception fetching classes: $e');
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
        appBar: AppBar(
          title: const Text('Profile Settings'),
          centerTitle: true,
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
                      // Profile Avatar
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100.r,
                                height: 100.r,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  currentUser.isReceptionist
                                      ? Icons.person
                                      : Icons.school,
                                  size: 50.r,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Responsive.verticalSpace(16),
                              Chip(
                                label: Text(
                                  currentUser.isReceptionist
                                      ? 'Receptionist'
                                      : currentUser.isTeacher
                                      ? 'Teacher'
                                      : 'Manager',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
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

                      // Save Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: SizedBox(
                          height: Responsive.buttonHeight(context),
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _saveProfile(currentUser),
                            icon: isLoading
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.save, size: 20.r),
                            label: Text(
                              isLoading ? 'Saving...' : 'Save Changes',
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
                      ),
                      Responsive.verticalSpace(16),

                      // Logout Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: SizedBox(
                          height: Responsive.buttonHeight(context),
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
                            icon: Icon(Icons.logout, size: 20.r),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: Responsive.borderRadius(12),
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
