/// Environment Configuration
/// Controls which environment the app runs in
enum Environment { development, production }

/// App Environment Configuration
class AppEnvironment {
  // Set this to Environment.production for release builds
  static const Environment current = Environment.development;

  /// Get base API URL based on environment
  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return _DevelopmentConfig.baseUrl;
      case Environment.production:
        return _ProductionConfig.baseUrl;
    }
  }

  /// Get Socket URL based on environment
  static String get socketUrl {
    switch (current) {
      case Environment.development:
        return _DevelopmentConfig.socketUrl;
      case Environment.production:
        return _ProductionConfig.socketUrl;
    }
  }

  /// Check if app is in production mode
  static bool get isProduction => current == Environment.production;

  /// Check if app is in development mode
  static bool get isDevelopment => current == Environment.development;
}

/// Development Environment Configuration
class _DevelopmentConfig {
  // For Android Emulator use: 10.0.2.2
  // For iOS Simulator use: localhost
  // For physical device use: your computer's IP (e.g., 192.168.1.100)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String socketUrl = 'http://10.0.2.2:3000';
}

/// Production Environment Configuration
/// IMPORTANT: Replace these URLs with your actual production server URLs
class _ProductionConfig {
  // TODO: Replace with your production server URL
  static const String baseUrl = 'https://your-production-api.com/api';
  static const String socketUrl = 'https://your-production-api.com';
}
