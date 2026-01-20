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
        HealthRoutes,
        HttpEmailService,
        JWTSecurityService,
        SecurityService,
        addRoutes;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, GetItInjector, LogService;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' show JWT;
import 'package:open_api_server/open_api_server.dart';
import 'package:user_server/user_server.dart';
import 'env/env.dart';

Future<DependencyInjector> registryInjectors() async {
  final logger = LogService.getLogger('EMS SERVER V1');
  logger.info('Iniciando configuração de injeção de dependência.');

  final di = GetItInjector();

  // 1. Provedor de Banco de Dados Global
  final databaseProvider = DatabaseProvider();
  di.registerSingleton<DatabaseProvider>(databaseProvider);

  await databaseProvider.connect(
    host: Env.serverAddress,
    port: int.tryParse(EnvDatabase.dbPort) ?? 5433,
    name: EnvDatabase.dbDatabaseName,
    user: EnvDatabase.dbUsername,
    password: EnvDatabase.dbPassword,
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
    () => HealthRoutes(backendBaseApi: Env.backendPathApi),
  );
  addRoutes(di, di.get<HealthRoutes>(), security: false);

  di.registerLazySingleton<OpenApiRoutes>(
    () => OpenApiRoutes(backendBaseApi: Env.backendPathApi),
  );
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
  );

  logger.info('Injeção de dependência concluída.');
  return di;
}
