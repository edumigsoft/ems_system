import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';

import '../repository/user_repository.dart';
import '../routes/user_routes.dart';

/// Inicializa o módulo de usuários no servidor.
///
/// Registra o [UserRepository] e [UserRoutes] no injetor de dependências
/// e configura as rotas no servidor.
///
/// Exemplo:
/// ```dart
/// await initUserModule(
///   di: di,
///   backendBaseApi: '/api/v1',
/// );
/// ```
Future<void> initUserModule({
  required DependencyInjector di,
  required String backendBaseApi,
}) async {
  // O repository será registrado quando tivermos a implementação concreta
  // di.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(db));

  // Por enquanto, registramos apenas as rotas (depois de ter o repository)
  // di.registerLazySingleton<UserRoutes>(() => UserRoutes(di.get<UserRepository>()));

  // addRoutes será chamado quando o repository estiver implementado
  // await addRoutes(di, di.get<UserRoutes>());
}
