import 'dart:io';

import 'package:auth_server/auth_server.dart'
    show InitAuthModuleToServer, AuthMiddleware;
import 'package:core_server/core_server.dart'
    show
        AddRoutes,
        BCryptService,
        CryptService,
        DatabaseProvider,
        EmailConfig,
        EmailService,
        FileRoutes,
        HealthRoutes,
        HttpEmailService,
        JWTSecurityService,
        SecurityService,
        addRoutes;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, GetItInjector, LogService, StorageService;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' show JWT;
import 'package:notebook_server/notebook_server.dart'
    show InitNotebookModuleToServer;
import 'package:open_api_server/open_api_server.dart';
import 'package:tag_server/tag_server.dart' show InitTagModuleToServer;
import 'package:user_server/user_server.dart';
import 'env/env.dart';

Future<DependencyInjector> registryInjectors() async {
  final logger = LogService.getLogger('EMS SERVER V1');
  logger.info('Iniciando configuração de injeção de dependência.');

  final di = GetItInjector();

  // 1. Provedor de Banco de Dados Global
  final databaseProvider = DatabaseProvider();
  di.registerSingleton<DatabaseProvider>(databaseProvider);

  final dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
  final dbPort =
      int.tryParse(Platform.environment['DB_PORT'] ?? EnvDatabase.dbPort) ??
      5432;
  final dbUser = Platform.environment['DB_USER'] ?? EnvDatabase.dbUser;
  final dbPass = Platform.environment['DB_PASS'] ?? EnvDatabase.dbPass;
  final dbName = Platform.environment['DB_NAME'] ?? EnvDatabase.dbName;

  await databaseProvider.connect(
    host: dbHost,
    port: dbPort,
    name: dbName,
    user: dbUser,
    password: dbPass,
    useSsl: false,
  );

  // 2. Infraestrutura de Segurança e Rotas
  di.registerLazySingleton<CryptService>(BCryptService.new);

  di.registerLazySingleton<SecurityService<JWT>>(
    () => JWTSecurityService(jwtKey: Env.jwtKey),
  );

  di.registerLazySingleton<SecurityService<dynamic>>(
    () => di.get<SecurityService<JWT>>() as SecurityService<dynamic>,
  );

  di.registerLazySingleton<EmailService>(
    () => HttpEmailService(EmailConfig.fromEnv()),
  );

  // Registro do AddRoutes (Lazy - depende do AuthRequired)
  di.registerLazySingleton<AddRoutes>(
    () => AddRoutes(
      Env.jwtKey,
      null, //di.get<AuthRequired>(),
    ),
  );

  // 3. Rotas Base e Documentação (dependem de AddRoutes estar configurado corretamente)
  di.registerLazySingleton<HealthRoutes>(
    () => HealthRoutes(
      backendBaseApi: Env.backendPathApi,
      version: Platform.environment['APP_VERSION'] ?? 'unknown',
      environment:
          Platform.environment['ENV'] ?? Platform.environment['ENVIRONMENT'],
    ),
  );
  addRoutes(di, di.get<HealthRoutes>(), security: false);

  di.registerLazySingleton<OpenApiRoutes>(
    () => OpenApiRoutes(backendBaseApi: Env.backendPathApi),
  );
  addRoutes(di, di.get<OpenApiRoutes>(), security: false);

  // 4. Inicialização dos Módulos (Orquestração)
  // IMPORTANTE: Resolvendo dependência circular Auth ↔ User:
  // - UserRoutes precisa de AuthMiddleware
  // - AuthService precisa de UserRepository
  //
  // Solução: Registrar AuthMiddleware ANTES de inicializar User module

  // Pré-registro do AuthMiddleware (depende apenas de SecurityService)
  di.registerLazySingleton<AuthMiddleware>(
    () => AuthMiddleware(di.get<SecurityService<dynamic>>()),
  );

  await InitUserModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
  );

  // Fase 2: Inicializar Auth completo (agora UserRepository está disponível)
  await InitAuthModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
    security: false,
    accessTokenExpiresMinutes: Env.accessTokenExpiresMinutes,
    refreshTokenExpiresDays: Env.refreshTokenExpiresDays,
    verificationLinkBaseUrl: Env.verificationLinkBaseUrl,
  );

  await InitTagModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
    security: false,
  );

  await InitNotebookModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
    security: false,
  );

  // 5. File Routes
  di.registerLazySingleton<FileRoutes>(
    () => FileRoutes(
      di.get<StorageService>(),
      di.get<AuthMiddleware>(),
      backendBaseApi: Env.backendPathApi,
    ),
  );
  addRoutes(di, di.get<FileRoutes>(), security: false);

  logger.info('Injeção de dependência concluída.');
  return di;
}
