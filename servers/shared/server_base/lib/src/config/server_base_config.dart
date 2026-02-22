class ServerBaseConfig {
  final String dbHost;
  final String dbName;
  final String dbUser;
  final String dbPass;
  final int dbPort;
  final bool dbUseSsl;
  final String jwtKey;
  final String backendPathApi;
  final int accessTokenExpiresMinutes;
  final int refreshTokenExpiresDays;
  final String verificationLinkBaseUrl;
  final String? appVersion;
  final String? environment;

  const ServerBaseConfig({
    required this.dbHost,
    required this.dbName,
    required this.dbUser,
    required this.dbPass,
    required this.dbPort,
    required this.dbUseSsl,
    required this.jwtKey,
    required this.backendPathApi,
    required this.accessTokenExpiresMinutes,
    required this.refreshTokenExpiresDays,
    required this.verificationLinkBaseUrl,
    this.appVersion,
    this.environment,
  });
}
