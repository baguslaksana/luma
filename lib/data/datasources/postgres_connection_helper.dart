import 'package:postgres/postgres.dart';
import '../../core/config/database_config.dart';

class PostgresConnectionHelper {
  static Future<Connection?> openConnection() async {
    try {
      final endpoint = Endpoint(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        database: DatabaseConfig.database,
        username: DatabaseConfig.username,
        password: DatabaseConfig.password,
      );

      final connection = await Connection.open(
        endpoint,
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 3),
        ),
      );
      return connection;
    } catch (e) {
      return null;
    }
  }
}
