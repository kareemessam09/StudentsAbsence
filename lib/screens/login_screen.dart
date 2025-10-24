import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/user_cubit.dart';
import '../cubits/user_state.dart';
import '../utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<UserCubit>();
      cubit.login(_emailController.text.trim(), _passwordController.text);
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
        backgroundColor: const Color(0xFFF5F7FA),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Responsive.verticalSpace(40),

                      // App Logo/Title Animation
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            Container(
                              width: 120.r,
                              height: 120.r,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1565C0,
                                    ).withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'logo.png',
                                  width: 120.r,
                                  height: 120.r,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Responsive.verticalSpace(24),
                            Text(
                              'StudentNotifier',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32.sp,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                            Responsive.verticalSpace(8),
                            Text(
                              'Welcome back! Login to continue',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 14.sp,
                              ),
                            ),
                            Responsive.verticalSpace(48),
                          ],
                        ),
                      ),

                      // Email Field
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(fontSize: 14.sp),
                            prefixIcon: Icon(Icons.email_outlined, size: 20.r),
                            border: OutlineInputBorder(
                              borderRadius: Responsive.borderRadius(12),
                            ),
                          ),
                          style: TextStyle(fontSize: 14.sp),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                        ),
                      ),
                      Responsive.verticalSpace(16),

                      // Password Field
                      FadeInRight(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
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
                          style: TextStyle(fontSize: 14.sp),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          enabled: !isLoading,
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                      ),
                      Responsive.verticalSpace(32),

                      // Login Button with Gradient
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
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
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
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
                                    'Login',
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

                      // Signup Link
                      FadeIn(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
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
                      Responsive.verticalSpace(32),
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
