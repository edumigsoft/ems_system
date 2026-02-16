import 'dart:io';

import 'routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rotas para verificação de saúde da aplicação.
///
/// Fornece endpoint de health check para monitoramento da API.
class HealthRoutes extends Routes {
  final String _backendBaseApi;
  final String _version;
  final String _environment;

  HealthRoutes({
    required String backendBaseApi,
    required String version,
    String? environment,
  })  : _backendBaseApi = backendBaseApi,
        _version = version,
        _environment = environment ??
            Platform.environment['ENV'] ??
            Platform.environment['ENVIRONMENT'] ??
            'development';

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
        'env': _environment,
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
