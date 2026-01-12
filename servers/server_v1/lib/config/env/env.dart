import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'DB_USERNAME')
  static const String dbUsername = _Env.dbUsername;
  @EnviedField(varName: 'DB_PASSWORD', obfuscate: true)
  static final String dbPassword = _Env.dbPassword;
  @EnviedField(varName: 'DB_HOST')
  static const String dbHost = _Env.dbHost;
  @EnviedField(varName: 'DB_PORT')
  static const String dbPort = _Env.dbPort;
  @EnviedField(varName: 'DB_DATABASE_NAME')
  static const String dbDatabaseName = _Env.dbDatabaseName;
  @EnviedField(varName: 'DB_SCHEMA_VERSION')
  static const int dbSchemaVersion = _Env.dbSchemaVersion;
  @EnviedField(varName: 'SERVER_ADDRESS')
  static const String serverAddress = _Env.serverAddress;
  @EnviedField(varName: 'SERVER_PORT')
  static int serverPort = _Env.serverPort;
  @EnviedField(varName: 'JWT_KEY')
  static const String jwtKey = _Env.jwtKey;
  @EnviedField(varName: 'ENABLE_DOCS', defaultValue: 'true')
  static const bool enableDocs = _Env.enableDocs;
  @EnviedField(varName: 'BACKEND_PATH_API')
  static const String backendPathApi = _Env.backendPathApi;
  @EnviedField(
    varName: 'ALLOWED_ORIGINS',
    defaultValue: 'http://localhost:${_Env.serverPort}',
  )
  static const String allowedOrigins =
      '${_Env.allowedOrigins}:${_Env.serverPort}';
}
