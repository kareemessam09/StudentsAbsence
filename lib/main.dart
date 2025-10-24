import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/service_locator.dart';
import 'cubits/notification_cubit.dart';
import 'cubits/user_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/receptionist_screen.dart';
import 'screens/teacher_screen.dart';
import 'screens/manager_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const StudentNotifier());
}

class StudentNotifier extends StatelessWidget {
  const StudentNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = UserCubit();
            // Check for saved login on app start
            cubit.checkAuthStatus();
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = NotificationCubit();
            // Load notifications on app start (after login)
            return cubit;
          },
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 11 Pro dimensions as base
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'StudentNotifier',
            debugShowCheckedModeBanner: false,

            // Responsive wrapper
            builder: (context, child) {
              return ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                    start: 1921,
                    end: double.infinity,
                    name: '4K',
                  ),
                ],
              );
            },

            // Material 3 with light theme and Google Fonts
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(),
            ),

            // Material 3 with dark theme and Google Fonts
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            ),

            // Follow system theme mode
            themeMode: ThemeMode.system,

            // Named routes with custom transitions
            initialRoute: '/login',
            onGenerateRoute: (settings) {
              Widget page;

              switch (settings.name) {
                case '/login':
                  page = const LoginScreen();
                  break;
                case '/signup':
                  page = const SignupScreen();
                  break;
                case '/receptionist':
                  page = const ReceptionistScreen();
                  break;
                case '/teacher':
                  page = const TeacherScreen();
                  break;
                case '/manager':
                  page = const ManagerScreen();
                  break;
                case '/profile':
                  page = const ProfileScreen();
                  break;
                default:
                  page = const LoginScreen();
              }

              // Custom page transition with fade and slide
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.05, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var slideTween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var fadeTween = Tween(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(slideTween),
                        child: FadeTransition(
                          opacity: animation.drive(fadeTween),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 300),
              );
            },
          );
        },
      ),
    );
  }
}
