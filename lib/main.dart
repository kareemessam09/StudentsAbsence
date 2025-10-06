import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cubits/request_cubit.dart';
import 'cubits/user_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/receptionist_screen.dart';
import 'screens/teacher_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const StudentNotifier());
}

class StudentNotifier extends StatelessWidget {
  const StudentNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => RequestCubit()),
      ],
      child: MaterialApp(
        title: 'StudentNotifier',
        debugShowCheckedModeBanner: false,

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
      ),
    );
  }
}
