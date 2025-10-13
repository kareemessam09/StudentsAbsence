import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/user_cubit.dart';
import '../cubits/user_state.dart';
import '../models/user_model.dart';
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
  String? _selectedClass;

  final List<String> _availableClasses = [
    'Class A',
    'Class B',
    'Class C',
    'Class D',
    'Class E',
  ];

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
      _selectedClass = user.className;
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

    // Update class name if teacher and changed
    if (currentUser.isTeacher &&
        _selectedClass != null &&
        _selectedClass != currentUser.className) {
      await cubit.updateClassName(_selectedClass!);
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
                                      : 'Dean',
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

                      // Class Selection (for Teachers only)
                      if (currentUser.isTeacher)
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: DropdownButtonFormField<String>(
                            value: _selectedClass,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Managed Class',
                              labelStyle: TextStyle(fontSize: 14.sp),
                              prefixIcon: Icon(
                                Icons.class_outlined,
                                size: 20.r,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: Responsive.borderRadius(12),
                              ),
                            ),
                            items: _availableClasses.map((className) {
                              return DropdownMenuItem(
                                value: className,
                                child: Text(
                                  className,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedClass = value;
                                    });
                                  },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a class';
                              }
                              return null;
                            },
                          ),
                        ),

                      if (currentUser.isTeacher) Responsive.verticalSpace(16),

                      // Info Card for Teachers
                      if (currentUser.isTeacher)
                        FadeIn(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 400),
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
                                      'You can change the class you manage. This will update which attendance requests you see.',
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
