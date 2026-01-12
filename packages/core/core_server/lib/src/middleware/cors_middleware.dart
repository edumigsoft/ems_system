import 'package:shelf/shelf.dart';

Middleware corsMiddleware({
  List<String> allowedOrigins = const ['http://127.0.0.1:3000'],
  List<String> allowedMethods = const [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'OPTIONS',
  ],
  List<String> allowedHeaders = const ['Authorization', 'Content-Type'],
}) {
  return (Handler handler) {
    return (Request request) {
      final origin = request.headers['origin'] ?? '';

      // Verifica se a origem é permitida
      if (allowedOrigins.contains(origin)) {
        // Responde ao preflight (OPTIONS)
        if (request.method == 'OPTIONS') {
          return Response.ok(
            '',
            headers: {
              'access-control-allow-origin': origin,
              'access-control-allow-methods': allowedMethods.join(','),
              'access-control-allow-headers': allowedHeaders.join(','),
              'access-control-max-age': '86400', // 24h
            },
          );
        }

        // Para qualquer outra requisição, modifica a resposta com CORS
        final futureResponse = Future.value(handler(request));
        return futureResponse.then((response) {
          return response.change(
            headers: {
              'access-control-allow-origin': origin,
              ...response.headers,
            },
          );
        });
      }

      // Se a origem não for permitida, apenas passa adiante
      return handler(request);
    };
  };
}
