import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/user_cubit.dart';
import '../cubits/user_state.dart';
import '../utils/responsive.dart';
import '../models/class_model.dart';
// TODO: Re-add when backend supports public /classes endpoint:
// import '../services/class_service.dart';
// import '../config/service_locator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'receptionist';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // For teachers - class selection
  List<ClassModel> _availableClasses = [];
  Set<String> _selectedClassIds = {};
  bool _handlesAllClasses = false;
  bool _isLoadingClasses = false;

  // TODO: Re-add when backend supports public /classes endpoint:
  // final ClassService _classService = getIt<ClassService>();

  @override
  void initState() {
    super.initState();
    // TODO: Uncomment when backend /classes endpoint allows public access:
    // _fetchAvailableClasses();
  }

  // TODO: Add method to fetch classes when backend supports public /classes endpoint
  // Future<void> _fetchAvailableClasses() async { ... }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<UserCubit>();

      // For teachers, validate class selection if not handling all classes
      if (_selectedRole == 'teacher' &&
          !_handlesAllClasses &&
          _availableClasses.isNotEmpty &&
          _selectedClassIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please select at least one class or enable "Handle All Classes"',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Send the selected role directly to backend
      // Backend accepts: receptionist, teacher, manager
      // TODO: Add classIds parameter when backend supports it during registration
      cubit.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        isManager: _selectedRole == 'manager', // For backward compatibility
        role: _selectedRole, // Send actual role to backend
        // classIds: _selectedClassIds.toList(), // TODO: Uncomment when backend supports
        // handlesAllClasses: _handlesAllClasses, // TODO: Uncomment when backend supports
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          // Navigate based on role
          if (state.user.isReceptionist) {
            Navigator.pushReplacementNamed(context, '/receptionist');
          } else if (state.user.isTeacher) {
            Navigator.pushReplacementNamed(context, '/teacher');
          } else if (state.user.isManager) {
            Navigator.pushReplacementNamed(context, '/manager');
          }
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
        appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final isLoading = state is UserLoading;

            return Responsive.centerContent(
              context: context,
              child: SingleChildScrollView(
                padding: Responsive.padding(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: Responsive.borderRadius(16),
                              child: Image.asset(
                                'logo.png',
                                width: 120.r,
                                height: 120.r,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Responsive.verticalSpace(16),
                            Text(
                              'Join StudentNotifier',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28.sp,
                              ),
                            ),
                            Responsive.verticalSpace(8),
                            Text(
                              'Create your account to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontSize: 14.sp,
                              ),
                            ),
                            Responsive.verticalSpace(32),
                          ],
                        ),
                      ),

                      // Name Field
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: TextFormField(
                          controller: _nameController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
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

                      // Role Selection
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Role',
                            labelStyle: TextStyle(fontSize: 14.sp),
                            prefixIcon: Icon(Icons.work_outline, size: 20.r),
                            border: OutlineInputBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'receptionist',
                              child: Text(
                                'Receptionist',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'teacher',
                              child: Text(
                                'Teacher',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'manager',
                              child: Text(
                                'Manager',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Class Selection (for teachers only)
                      if (_selectedRole == 'teacher')
                        FadeIn(
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // All Classes Checkbox
                              CheckboxListTile(
                                title: Text(
                                  'Handle All Classes',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'You will see all attendance requests',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                value: _handlesAllClasses,
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _handlesAllClasses = value ?? false;
                                          if (_handlesAllClasses) {
                                            _selectedClassIds.clear();
                                          }
                                        });
                                      },
                                contentPadding: EdgeInsets.zero,
                              ),

                              if (!_handlesAllClasses) ...[
                                Responsive.verticalSpace(8),
                                Text(
                                  'Select Classes to Manage:',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Responsive.verticalSpace(8),

                                // Show loading, empty state, or classes list
                                if (_isLoadingClasses)
                                  Container(
                                    padding: Responsive.padding(all: 24),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                      ),
                                      borderRadius: Responsive.borderRadius(12),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (_availableClasses.isEmpty)
                                  Container(
                                    padding: Responsive.padding(all: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.5),
                                      ),
                                      borderRadius: Responsive.borderRadius(12),
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withOpacity(0.3),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: theme.colorScheme.primary,
                                          size: 32.r,
                                        ),
                                        Responsive.verticalSpace(8),
                                        Text(
                                          'Classes will be assigned after signup',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Responsive.verticalSpace(4),
                                        Text(
                                          'After creating your teacher account, a manager can assign classes to you from the admin panel.',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                      ),
                                      borderRadius: Responsive.borderRadius(12),
                                    ),
                                    child: Column(
                                      children: _availableClasses.map((
                                        classModel,
                                      ) {
                                        return CheckboxListTile(
                                          title: Text(
                                            classModel.name,
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          subtitle:
                                              classModel.description.isNotEmpty
                                              ? Text(
                                                  classModel.description,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                  ),
                                                )
                                              : null,
                                          value: _selectedClassIds.contains(
                                            classModel.id,
                                          ),
                                          onChanged: isLoading
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      _selectedClassIds.add(
                                                        classModel.id,
                                                      );
                                                    } else {
                                                      _selectedClassIds.remove(
                                                        classModel.id,
                                                      );
                                                    }
                                                  });
                                                },
                                          dense: true,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      if (_selectedRole == 'teacher')
                        Responsive.verticalSpace(16),

                      // Password Field
                      FadeInRight(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(fontSize: 14.sp),
                            prefixIcon: Icon(Icons.lock_outline, size: 20.r),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20.r,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Confirm Password Field
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(fontSize: 14.sp),
                            prefixIcon: Icon(Icons.lock_outline, size: 20.r),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20.r,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                        ),
                      ),
                      Responsive.verticalSpace(32),

                      // Signup Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: SizedBox(
                          height: Responsive.buttonHeight(context),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: Responsive.borderRadius(12),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 24.r,
                                    width: 24.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Login Link
                      FadeIn(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
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
