import 'package:shelf/shelf.dart';

/// Middleware que valida a API Key enviada pelo cliente no header `x-api-key`.
///
/// Rejeita com HTTP 401 qualquer requisição sem a chave correta, usando
/// mensagem genérica para não revelar ao atacante qual condição falhou.
class ApiKeyMiddleware {
  final String apiKey;
  static const _headerName = 'x-api-key';

  static const _unauthorizedBody =
      '{"error": "Unauthorized", "message": "Acesso negado"}';

  const ApiKeyMiddleware({required this.apiKey});

  Middleware get middleware {
    return (Handler handler) {
      return (Request request) async {
        final key = request.headers[_headerName];
        if (key == null || key != apiKey) {
          return Response.unauthorized(
            _unauthorizedBody,
            headers: {'content-type': 'application/json'},
          );
        }
        return handler(request);
      };
    };
  }
}
