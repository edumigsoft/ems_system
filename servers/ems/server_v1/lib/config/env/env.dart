import 'package:envied/envied.dart';

part 'env.g.dart';

// Apenas defaults não-sensíveis e agnósticos de ambiente.
// Todos os secrets (JWT_KEY, DB_*, API_KEY, etc.) são obrigatoriamente
// injetados via Platform.environment em runtime — sem fallback em build-time.
@Envied(path: '.env.defaults', name: 'Env', useConstantCase: true)
final class Env {
  @EnviedField()
  static const int serverPort = _Env.serverPort;

  @EnviedField()
  static const bool enableDocs = _Env.enableDocs;

  @EnviedField()
  static const String backendPathApi = _Env.backendPathApi;

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
}
