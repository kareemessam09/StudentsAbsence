import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../services/class_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../services/statistics_service.dart';
import '../services/socket_service.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Setup all services for dependency injection
/// Call this once at app startup in main()
Future<void> setupServiceLocator() async {
  // Base API Service (Singleton)
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Register all service classes (using the same ApiService instance)
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<StudentService>(
    () => StudentService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<ClassService>(
    () => ClassService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<StatisticsService>(
    () => StatisticsService(getIt<ApiService>()),
  );

  // Socket Service (Singleton) for real-time updates
  getIt.registerLazySingleton<SocketService>(() => SocketService());
}
