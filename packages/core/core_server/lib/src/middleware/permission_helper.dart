import 'package:shelf/shelf.dart';
import '../utils/http_response_helper.dart';

/// Helper para verificação de permissões em rotas.
///
/// Padroniza a verificação de permissões baseadas em roles do usuário.
class PermissionHelper {
  /// Verifica se o usuário tem permissão para a operação.
  ///
  /// [request] - Requisição HTTP
  /// [owner] - Se true, requer role de owner
  /// [admin] - Se true, requer role de admin
  /// [teacher] - Se true, requer role de teacher
  /// [student] - Se true, requer role de student
  ///
  /// Retorna null se tiver permissão, ou Response de erro caso contrário.
  static Response? checkPermission(
    Request request, {
    bool owner = false,
    bool admin = false,
    bool manager = false,
    bool teacher = false,
    bool aoe = false,
    bool student = false,
    String? userId,
  }) {
    if (userId != null) {
      final userDetails = request.context['user_details'];
      if (userDetails != null) {
        try {
          final requesterId = (userDetails as dynamic).id as String;
          if (requesterId == userId) {
            return null;
          }
        } catch (_) {}
      }
    }

    final userRoles = request.context['userRoles'] as List<String>?;

    if (userRoles == null || userRoles.isEmpty) {
      return HttpResponseHelper.error('Usuário não autenticado', code: 401);
    }

    final hasPermission =
        (owner && userRoles.contains('owner')) ||
        (admin && userRoles.contains('admin')) ||
        (manager && userRoles.contains('manager')) ||
        (teacher && userRoles.contains('teacher')) ||
        (aoe && userRoles.contains('aoe')) ||
        (student && userRoles.contains('student'));

    if (!hasPermission) {
      return HttpResponseHelper.error(
        'Você não tem permissão para realizar esta operação',
        code: 403,
      );
    }

    return null;
  }
}
