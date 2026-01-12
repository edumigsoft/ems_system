import 'package:core_server/core_server.dart'
    show
        AddRoutes,
        // AuthRequired,
        BCryptService,
        DatabaseProvider,
        HealthRoutes,
        JWTSecurityService,
        SecurityService,
        addRoutes;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, GetItInjector, LogService;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' show JWT;
import 'package:open_api_server/open_api_server.dart';
import 'env/env.dart';

Future<DependencyInjector> registryInjectors() async {
  final logger = LogService.getLogger('SMS SERVER V1');
  logger.info('Iniciando configuração de injeção de dependência.');

  final di = GetItInjector();

  // 1. Provedor de Banco de Dados Global
  final databaseProvider = DatabaseProvider();
  di.registerSingleton<DatabaseProvider>(databaseProvider);

  await databaseProvider.connect(
    host: Env.serverAddress,
    port: 5432,
    name: Env.dbDatabaseName,
    user: Env.dbDatabaseName,
    password: Env.dbPassword,
    useSsl: false,
  );

  // 2. Infraestrutura de Segurança e Rotas
  di.registerLazySingleton<BCryptService>(BCryptService.new);

  di.registerLazySingleton<SecurityService<JWT>>(
    () => JWTSecurityService(jwtKey: Env.jwtKey),
  );

  di.registerLazySingleton<SecurityService<dynamic>>(
    () => di.get<SecurityService<JWT>>() as SecurityService<dynamic>,
  );

  // Registro do AuthRequired (Lazy - depende do UserRepository que será registrado no InitUserModule)
  // di.registerLazySingleton<AuthRequired>(
  //   () => AuthRequiredImpl(
  //     secret: Env.jwtKey,
  //     userRepository: di.get<UserRepository>(),
  //   ),
  // );

  // Registro do AddRoutes (Lazy - depende do AuthRequired)
  di.registerLazySingleton<AddRoutes>(
    () => AddRoutes(
      Env.jwtKey,
      null, //di.get<AuthRequired>(),
    ),
  );

  // 4. Inicialização dos Módulos (Orquestração)
  // InitUserModuleToServer(di: di, backendBaseApi: Env.backendPathApi);
  // InitAcademicConfigModuleToServer(di: di, backendBaseApi: Env.backendPathApi);
  // InitAcademicStructureModuleToServer(
  //   di: di,
  //   backendBaseApi: Env.backendPathApi,
  // );

  // 3. Rotas Base e Documentação (dependem de AddRoutes estar configurado corretamente)
  di.registerLazySingleton<HealthRoutes>(
    () => HealthRoutes(backendBaseApi: Env.backendPathApi),
  );
  addRoutes(di, di.get<HealthRoutes>(), security: false);

  di.registerLazySingleton<OpenApiRoutes>(
    () => OpenApiRoutes(backendBaseApi: Env.backendPathApi),
  );
  addRoutes(di, di.get<OpenApiRoutes>(), security: false);

  // InitAuthModuleToServer(
  //   di: di,
  //   backendBaseApi: Env.backendPathApi,
  //   security: false,
  // );

  // InitSchoolModuleToServer(di: di, backendBaseApi: Env.backendPathApi);

  // InitAuraModuleToServer(di: di, backendBaseApi: Env.backendPathApi);

  logger.info('Injeção de dependência concluída.');
  return di;
}
