import 'dart:io';

class DatabaseConfig {
  DatabaseConfig._();

  /// Default database connection settings
  /// On Android emulator, '10.0.2.2' points to the host machine's localhost.
  /// On Linux, macOS, Windows desktop, or Web, use '127.0.0.1' or 'localhost'.
  static String get host {
    try {
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  static const int port = 5432;
  static const String database = 'luma_elearning';
  static const String username = 'luma_user';
  static const String password = 'luma_password123';

  /// Whether SSL is required. For local PostgreSQL / Docker, SSL is disabled.
  static const bool ssl = false;
}
