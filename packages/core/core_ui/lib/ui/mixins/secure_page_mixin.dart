import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show UserRole;

/// Mixin opcional para páginas que precisam de validações extras de segurança.
///
/// Este mixin NÃO substitui a proteção primária de rotas (RoleGuard ou
/// guard no ViewModel), mas fornece uma camada adicional para:
/// - Logs de acesso e auditoria
/// - Validações específicas da página
/// - Verificações granulares de permissões
///
/// Exemplo de uso:
/// ```dart
/// class _ManageUsersPageState extends State<ManageUsersPage>
///     with SecurePageMixin {
///
///   @override
///   List<UserRole> get requiredRoles => [UserRole.admin, UserRole.owner];
///
///   @override
///   UserRole? get currentUserRole => widget.viewModel.currentUser?.role;
///
///   @override
///   void initState() {
///     super.initState();
///     logPageAccess(); // Opcional: registra acesso
///     validateCustomPermissions(); // Opcional: validações extras
///   }
/// }
/// ```
mixin SecurePageMixin<T extends StatefulWidget> on State<T> {
  /// Roles necessárias para acessar esta página
  List<UserRole> get requiredRoles;

  /// Role do usuário atualmente autenticado
  UserRole? get currentUserRole;

  /// Verifica se o usuário atual tem permissão para acessar a página
  bool get hasAccess {
    if (currentUserRole == null) return false;
    return requiredRoles.contains(currentUserRole!);
  }

  /// Registra acesso à página (para auditoria/analytics)
  void logPageAccess() {
    if (currentUserRole != null) {
      debugPrint(
        '[AUDIT] Acesso à página ${widget.runtimeType} '
        'por usuário com role ${currentUserRole!.name}',
      );
    }
  }

  /// Validações customizadas de permissões
  ///
  /// Sobrescreva este método para adicionar verificações específicas
  /// da sua página. Exemplo:
  /// ```dart
  /// @override
  /// void validateCustomPermissions() {
  ///   super.validateCustomPermissions();
  ///   if (!canEditSpecificResource()) {
  ///     showWarning('Você pode visualizar mas não editar');
  ///   }
  /// }
  /// ```
  void validateCustomPermissions() {
    // Override em páginas específicas se necessário
  }

  /// Mostra um alerta de permissão insuficiente
  void showInsufficientPermissionWarning(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Verifica se o usuário tem uma role específica ou superior
  bool hasRoleOrHigher(UserRole minimumRole) {
    if (currentUserRole == null) return false;
    return currentUserRole! >= minimumRole;
  }

  /// Verifica se o usuário tem exatamente uma role específica
  bool hasExactRole(UserRole role) {
    if (currentUserRole == null) return false;
    return currentUserRole! == role;
  }
}
