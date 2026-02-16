import 'routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rotas para verificação de saúde da aplicação.
///
/// Fornece endpoint de health check para monitoramento da API.
class HealthRoutes extends Routes {
  final String _backendBaseApi;
  final String _version;

  HealthRoutes({
    required String backendBaseApi,
    required String version,
  })  : _backendBaseApi = backendBaseApi,
        _version = version;

  @override
  String get path => '$_backendBaseApi/health';

  /// Router com endpoint de health check.
  ///
  /// Endpoints disponíveis:
  /// - `GET /` - Retorna status de saúde da aplicação
  @override
  Router get router {
    final router = Router();

    router.get('/', (Request request) {
      final status = {
        'status': 'OK',
        'timestamp': DateTime.now().toIso8601String(),
        'uptime': 'since startup',
        'env': 'development', // Em produção, mude
        'version': _version,
      };

      return Response.ok(
        status.toString(),
        headers: {
          'content-type': 'application/health+json',
          'cache-control': 'no-cache',
        },
      );
    });

    return router;
  }
}
