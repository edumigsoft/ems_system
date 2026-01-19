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

  // Auth Configuration
  @EnviedField(varName: 'ACCESS_TOKEN_EXPIRES_MINUTES', defaultValue: 15)
  static const int accessTokenExpiresMinutes = _Env.accessTokenExpiresMinutes;

  @EnviedField(varName: 'REFRESH_TOKEN_EXPIRES_DAYS', defaultValue: 7)
  static const int refreshTokenExpiresDays = _Env.refreshTokenExpiresDays;

  @EnviedField(varName: 'MAX_LOGIN_ATTEMPTS_PER_ACCOUNT', defaultValue: 5)
  static const int maxLoginAttemptsPerAccount = _Env.maxLoginAttemptsPerAccount;

  @EnviedField(varName: 'MAX_LOGIN_ATTEMPTS_PER_IP', defaultValue: 10)
  static const int maxLoginAttemptsPerIp = _Env.maxLoginAttemptsPerIp;

  @EnviedField(varName: 'ACCOUNT_LOCKOUT_MINUTES', defaultValue: 30)
  static const int accountLockoutMinutes = _Env.accountLockoutMinutes;

  @EnviedField(varName: 'IP_BLOCK_MINUTES', defaultValue: 15)
  static const int ipBlockMinutes = _Env.ipBlockMinutes;

  // Email Service
  @EnviedField(varName: 'EMAIL_SERVICE_HOST')
  static const String emailServiceHost = _Env.emailServiceHost;

  @EnviedField(varName: 'EMAIL_SERVICE_PORT')
  static const int emailServicePort = _Env.emailServicePort;

  @EnviedField(varName: 'EMAIL_SERVICE_API_KEY', obfuscate: true)
  static final String emailServiceApiKey = _Env.emailServiceApiKey;
}
