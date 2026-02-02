import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show UserRole;
import '../view_models/auth_view_model.dart';

/// Widget que protege conteúdo baseado em roles de usuário.
///
/// Verifica se o usuário atual tem permissão para acessar o conteúdo.
/// Se não tiver, exibe uma página de acesso negado ou um widget customizado.
///
/// Exemplo:
/// ```dart
/// RoleGuard(
///   allowedRoles: [UserRole.admin, UserRole.owner],
///   authViewModel: authViewModel,
///   child: ManageUsersPage(),
/// )
/// ```
class RoleGuard extends StatelessWidget {
  /// Widget a ser exibido se o usuário tiver permissão
  final Widget child;

  /// Roles permitidas para acessar o conteúdo
  final List<UserRole> allowedRoles;

  /// Widget a ser exibido se o usuário não tiver permissão
  final Widget? fallback;

  /// ViewModel de autenticação para verificar o usuário atual
  final AuthViewModel authViewModel;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    required this.authViewModel,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        final currentUser = authViewModel.currentUser;

        // Se não há usuário autenticado ou role não permitida
        if (currentUser == null ||
            !allowedRoles.contains(currentUser.role)) {
          return fallback ?? _buildAccessDenied(context);
        }

        return child;
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acesso Negado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Você não tem permissão para acessar esta página',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta página requer permissões de: ${allowedRoles.map((r) => r.name).join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
