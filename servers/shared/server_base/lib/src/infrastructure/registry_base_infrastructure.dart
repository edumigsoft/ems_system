import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:core_server/core_server.dart'
    show
        AddRoutes,
        BCryptService,
        CryptService,
        DatabaseProvider,
        EmailConfig,
        EmailService,
        HealthRoutes,
        HttpEmailService,
        JWTSecurityService,
        SecurityService,
        addRoutes;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, GetItInjector, LogService;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' show JWT;
import 'package:open_api_server/open_api_server.dart';

import '../config/server_base_config.dart';

Future<DependencyInjector> registryBaseInfrastructure(
  ServerBaseConfig config, {
  String loggerName = 'SERVER',
}) async {
  final logger = LogService.getLogger(loggerName);
  logger.info('Iniciando configuração de injeção de dependência.');

  final di = GetItInjector();

  // Fase 1: Banco de Dados
  final databaseProvider = DatabaseProvider();
  di.registerSingleton<DatabaseProvider>(databaseProvider);

  await databaseProvider.connect(
    host: config.dbHost,
    port: config.dbPort,
    name: config.dbName,
    user: config.dbUser,
    password: config.dbPass,
    useSsl: config.dbUseSsl,
  );

  // Fase 2: Segurança
  di.registerLazySingleton<CryptService>(BCryptService.new);

  di.registerLazySingleton<SecurityService<JWT>>(
    () => JWTSecurityService(jwtKey: config.jwtKey),
  );

  di.registerLazySingleton<SecurityService<dynamic>>(
    () => di.get<SecurityService<JWT>>() as SecurityService<dynamic>,
  );

  di.registerLazySingleton<EmailService>(
    () => HttpEmailService(EmailConfig.fromEnv()),
  );

  // Fase 3: Rotas base
  di.registerLazySingleton<AddRoutes>(
    () => AddRoutes(config.jwtKey, null),
  );

  di.registerLazySingleton<HealthRoutes>(
    () => HealthRoutes(
      backendBaseApi: config.backendPathApi,
      version: config.appVersion ?? 'unknown',
      environment: config.environment,
    ),
  );
  addRoutes(di, di.get<HealthRoutes>(), security: false);

  di.registerLazySingleton<OpenApiRoutes>(
    () => OpenApiRoutes(backendBaseApi: config.backendPathApi),
  );
  addRoutes(di, di.get<OpenApiRoutes>(), security: false);

  // Fase 4a: Pré-registro do AuthMiddleware (resolve dependência circular Auth ↔ User)
  di.registerLazySingleton<AuthMiddleware>(
    () => AuthMiddleware(di.get<SecurityService<dynamic>>()),
  );

  return di;
}
