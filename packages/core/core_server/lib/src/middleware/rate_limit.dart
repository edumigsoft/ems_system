import 'dart:collection';

import 'package:shelf/shelf.dart';

/// Middleware de limitação de taxa de requisições (rate limiting).
///
/// Controla o número de requisições por IP em um período de tempo,
/// prevenindo abuso e sobrecarga do servidor.
class RateLimit {
  final int requestsPerPeriod;
  final Duration period;
  final Map<String, Queue<DateTime>> _requests = {};

  RateLimit({
    this.requestsPerPeriod = 10,
    this.period = const Duration(minutes: 1),
  });

  /// Middleware de limitação de taxa de requisições (rate limiting).
  ///
  /// Limita o número de requisições por IP no período configurado.
  /// Retorna HTTP 403 se o limite for excedido, com header 'retry-after'
  /// indicando quando o cliente pode tentar novamente.
  Middleware get middleware {
    return (Handler handler) {
      return (Request request) async {
        final ip = request.context['ip'] as String? ?? 'unknown';
        final now = DateTime.now();
        final queue = _requests.putIfAbsent(ip, Queue<DateTime>.new);

        // Remove requisições fora do período
        while (queue.isNotEmpty && queue.first.isBefore(now.subtract(period))) {
          queue.removeFirst();
        }

        if (queue.length >= requestsPerPeriod) {
          return Response.forbidden(
            'Limite de requisições excedido. Tente novamente mais tarde.',
            headers: {'retry-after': '${period.inSeconds}'},
          );
        }

        queue.add(now);

        // Adiciona IP ao contexto (opcional)
        final requestWithIp = request.change(
          context: {...request.context, 'ip': ip},
        );
        return await handler(requestWithIp);
      };
    };
  }
}
