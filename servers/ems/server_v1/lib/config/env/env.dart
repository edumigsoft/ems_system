import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(
  path: '../container/.env',
  name: 'EnvDatabase',
  useConstantCase: true,
)
final class EnvDatabase {
  @EnviedField()
  static const String dbUser = _EnvDatabase.dbUser;

  @EnviedField()
  static const String dbPass = _EnvDatabase.dbPass;

  @EnviedField()
  static const String dbHost = _EnvDatabase.dbHost;

  @EnviedField()
  static const String dbPort = _EnvDatabase.dbPort;

  @EnviedField()
  static const String dbName = _EnvDatabase.dbName;
}

@Envied(path: '.env', name: 'Env', useConstantCase: true)
final class Env {
  @EnviedField()
  static const String serverAddress = _Env.serverAddress;

  @EnviedField()
  static const int serverPort = _Env.serverPort;

  @EnviedField()
  static const String jwtKey = _Env.jwtKey;

  @EnviedField()
  static const bool enableDocs = _Env.enableDocs;

  @EnviedField()
  static const String backendPathApi = _Env.backendPathApi;

  @EnviedField(
    defaultValue: 'http://localhost:${_Env.serverPort}',
  )
  static const String allowedOrigins =
      '${_Env.allowedOrigins}:${_Env.serverPort}';

  @EnviedField()
  static const int accessTokenExpiresMinutes = _Env.accessTokenExpiresMinutes;

  @EnviedField()
  static const int refreshTokenExpiresDays = _Env.refreshTokenExpiresDays;

  @EnviedField()
  static const int maxLoginAttemptsPerAccount = _Env.maxLoginAttemptsPerAccount;

  @EnviedField()
  static const int maxLoginAttemptsPerIp = _Env.maxLoginAttemptsPerIp;

  @EnviedField()
  static const int accountLockoutMinutes = _Env.accountLockoutMinutes;

  @EnviedField()
  static const int ipBlockMinutes = _Env.ipBlockMinutes;

  @EnviedField()
  static const String verificationLinkBaseUrl = _Env.verificationLinkBaseUrl;

  // Email Service
  @EnviedField()
  static const String emailServiceHost = _Env.emailServiceHost;

  @EnviedField()
  static const int emailServicePort = _Env.emailServicePort;

  @EnviedField()
  static const String emailServiceApiKey = _Env.emailServiceApiKey;
}
