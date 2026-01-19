import 'package:shelf_router/shelf_router.dart';

/// Interface para definição de rotas de recursos da API.
///
/// Implementações desta interface devem definir o caminho base
/// e o router com todos os endpoints do recurso.
abstract class Routes {
  /// Caminho base para as rotas deste recurso.
  ///
  /// Exemplo: '/users', '/auth', '/health'
  String get path;

  /// Router configurado com todos os endpoints deste recurso.
  ///
  /// Contém as definições de rotas HTTP (GET, POST, PUT, DELETE, etc.)
  /// para o recurso gerenciado por esta classe.
  Router get router;

  final bool security;

  Routes({this.security = true});
}
