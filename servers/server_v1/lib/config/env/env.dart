import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
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
  @EnviedField(varName: 'SERVER_ADDRESS')
  static const String serverAddress = _Env.serverAddress;
  @EnviedField(varName: 'SERVER_PORT')
  // static const String serverPort = _Env.serverPort;
  static int serverPort = _Env.serverPort;
  @EnviedField(varName: 'JWT_KEY')
  static const String jwtKey = _Env.jwtKey;
  @EnviedField(varName: 'AES_KEY')
  static const String aesKey = _Env.aesKey;
  @EnviedField(varName: 'BACKEND_PATH_API')
  static const String backendPathApi = _Env.backendPathApi;
  @EnviedField(
    varName: 'ALLOWED_ORIGINS',
    defaultValue: 'http://localhost:${_Env.serverPort}',
  )
  static const String allowedOrigins =
      '${_Env.allowedOrigins}:${_Env.serverPort}';
  @EnviedField(varName: 'ENABLE_DOCS', defaultValue: 'true')
  static const bool enableDocs = _Env.enableDocs;
  @EnviedField(varName: 'DB_SCHEMA_VERSION')
  static const int dbSchemaVersion = _Env.dbSchemaVersion;
  @EnviedField(varName: 'ENCRYPTION_KEY')
  static const String encryptionKey = _Env.encryptionKey;
  @EnviedField(varName: 'ENCRYPTION_IV')
  static const String encryptionIv = _Env.encryptionIv;
  @EnviedField(varName: 'ACCESS_TOKEN_EXPIRES_DAYS')
  static const int accessTokenExpiresDays = _Env.accessTokenExpiresDays;
  @EnviedField(varName: 'REFRESH_TOKEN_EXPIRES_DAYS')
  static const int refreshTokenExpiresDays = _Env.refreshTokenExpiresDays;
  @EnviedField(varName: 'ACCESS_TOKEN_EXPIRES_SHORT_SECONDS')
  static const int accessTokenExpiresShortSeconds =
      _Env.accessTokenExpiresShortSeconds;
  @EnviedField(varName: 'REFRESH_TOKEN_EXPIRES_SHORT_SECONDS')
  static const int refreshTokenExpiresShortSeconds =
      _Env.refreshTokenExpiresShortSeconds;
  @EnviedField(varName: 'TEMP_PASSWORD_EXPIRES_DAYS')
  static const int tempPasswordExpiresDays = _Env.tempPasswordExpiresDays;
}
