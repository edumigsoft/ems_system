import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';

import '../routes/auth_routes.dart';
import '../middleware/auth_middleware.dart';

/// Inicializa o módulo de autenticação no servidor.
///
/// Registra o [AuthMiddleware], [AuthRoutes] e services no injetor
/// e configura as rotas no servidor.
///
/// Exemplo:
/// ```dart
/// await initAuthModule(
///   di: di,
///   backendBaseApi: '/api/v1',
/// );
/// ```
Future<void> initAuthModule({
  required DependencyInjector di,
  required String backendBaseApi,
}) async {
  // Registrar middleware
  di.registerLazySingleton<AuthMiddleware>(() => AuthMiddleware());

  // Registrar rotas
  di.registerLazySingleton<AuthRoutes>(() => AuthRoutes());

  // Adicionar rotas ao servidor
  await addRoutes(di, di.get<AuthRoutes>());
}
