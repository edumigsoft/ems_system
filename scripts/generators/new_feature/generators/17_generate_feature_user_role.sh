#!/bin/bash

# ============================================================================
# 17_generate_feature_user_role.sh - Gera componentes de FeatureUserRole
# ============================================================================
#
# Gera todos os componentes necessários para implementar FeatureUserRole
# em uma feature:
# - Tabela {feature}_user_role (Drift)
# - Repository implementation (implementa FeatureUserRoleRepository)
# - Service (lógica de negócio)
# - Routes (endpoints HTTP)
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de FeatureUserRole"
echo "=============================================="
echo ""

info "Este gerador cria a infraestrutura completa para controle"
info "de acesso baseado em papéis (owner, admin, manager, member, viewer)"
info "dentro do contexto de uma feature específica."
echo ""

ask "Nome da feature (snake_case, ex: project, finance)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade ID (camelCase, ex: projectId, financeId)" FEATURE_ID_NAME
validate_name "$FEATURE_ID_NAME" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
FEATURE_PASCAL=$(to_pascal_case "$FEATURE_NAME")
ROOT=$(get_project_root)
SERVER_PATH=$(get_server_package_path "$FEATURE_SNAKE")

validate_package_exists "$FEATURE_SNAKE" "server" || exit 1

# ============================================================================
# 1. Gerar Tabela Drift
# ============================================================================

TABLE_FILE="$SERVER_PATH/lib/src/database/tables/${FEATURE_SNAKE}_user_role_table.dart"
ensure_dir "$(dirname "$TABLE_FILE")"

progress "Gerando ${FEATURE_PASCAL}UserRoleTable..."

cat > "$TABLE_FILE" <<EOF
import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:auth_shared/auth_shared.dart'
    show FeatureUserRoleDetails, FeatureUserRole;
import 'package:auth_server/auth_server.dart' show FeatureUserRoleConverter;

/// Tabela de papéis de usuários no contexto de ${FEATURE_NAME}.
///
/// Armazena a relação entre usuários e seus papéis dentro de uma
/// instância específica da feature ${FEATURE_NAME}.
///
/// **Papéis disponíveis:** owner, admin, manager, member, viewer
/// (veja [FeatureUserRole] para detalhes de cada papel)
@UseRowClass(FeatureUserRoleDetails, constructor: 'create')
class ${FEATURE_PASCAL}UserRoles extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => '${FEATURE_SNAKE}_user_role';

  /// ID do usuário
  TextColumn get userId => text()();

  /// ID da instância de ${FEATURE_NAME}
  TextColumn get ${FEATURE_ID_NAME} => text()();

  /// Papel do usuário no contexto (owner, admin, manager, member, viewer)
  TextColumn get role => text()
      .map(const FeatureUserRoleConverter())
      .withDefault(const Constant('viewer'))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, ${FEATURE_ID_NAME}}
      ];
}
EOF

success "Tabela gerada!"
info "Arquivo: $TABLE_FILE"
echo ""

# ============================================================================
# 2. Gerar Repository Implementation
# ============================================================================

REPO_FILE="$SERVER_PATH/lib/src/repositories/${FEATURE_SNAKE}_user_role_repository.dart"
ensure_dir "$(dirname "$REPO_FILE")"

progress "Gerando ${FEATURE_PASCAL}UserRoleRepository..."

cat > "$REPO_FILE" <<'EOF_TEMPLATE'
import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart' show Result, Success, Failure, DataException, Unit;
import 'package:auth_shared/auth_shared.dart';
import '../database/${FEATURE_SNAKE}_database.dart';
import '../database/tables/${FEATURE_SNAKE}_user_role_table.dart';

part '${FEATURE_SNAKE}_user_role_repository.g.dart';

/// Implementação do repositório de papéis de usuários para ${FEATURE_NAME}.
///
/// Gerencia a persistência de [FeatureUserRole] no contexto de ${FEATURE_NAME}.
@DriftAccessor(tables: [${FEATURE_PASCAL}UserRoles])
class ${FEATURE_PASCAL}UserRoleRepository extends DatabaseAccessor<${FEATURE_PASCAL}Database>
    with _$${FEATURE_PASCAL}UserRoleRepositoryMixin
    implements FeatureUserRoleRepository {
  ${FEATURE_PASCAL}UserRoleRepository(super.db);

  @override
  Future<Result<FeatureUserRoleDetails>> grant(FeatureUserRoleCreate data) async {
    try {
      if (!data.isValid) {
        return Failure(DataException('Invalid role data'));
      }

      await into(${FEATURE_SNAKE}UserRoles).insertOnConflictUpdate(
        ${FEATURE_PASCAL}UserRolesCompanion(
          userId: Value(data.userId),
          ${FEATURE_ID_NAME}: Value(data.featureId),
          role: Value(data.role),
          isActive: const Value(true),
          isDeleted: const Value(false),
        ),
      );

      final result = await getUserRole(
        userId: data.userId,
        featureId: data.featureId,
      );

      return result.when(
        success: (details) => details != null
            ? Success(details)
            : Failure(DataException('Failed to retrieve created role')),
        failure: Failure.new,
      );
    } catch (e) {
      return Failure(DataException('Failed to grant role: $e'));
    }
  }

  @override
  Future<Result<Unit>> revoke({
    required String userId,
    required String featureId,
  }) async {
    try {
      final updated = await (update(${FEATURE_SNAKE}UserRoles)
            ..where((t) =>
                t.userId.equals(userId) & t.${FEATURE_ID_NAME}.equals(featureId)))
          .write(
        ${FEATURE_PASCAL}UserRolesCompanion(
          isDeleted: const Value(true),
          isActive: const Value(false),
        ),
      );

      if (updated == 0) {
        return Failure(DataException('Role not found'));
      }

      return const Success(Unit());
    } catch (e) {
      return Failure(DataException('Failed to revoke role: $e'));
    }
  }

  @override
  Future<Result<FeatureUserRoleDetails?>> getUserRole({
    required String userId,
    required String featureId,
  }) async {
    try {
      final query = select(${FEATURE_SNAKE}UserRoles)
        ..where((t) =>
            t.userId.equals(userId) &
            t.${FEATURE_ID_NAME}.equals(featureId) &
            t.isDeleted.equals(false));

      final role = await query.getSingleOrNull();
      return Success(role);
    } catch (e) {
      return Failure(DataException('Failed to get user role: $e'));
    }
  }

  @override
  Future<Result<List<FeatureUserRoleDetails>>> listFeatureMembers({
    required String featureId,
    bool includeDeleted = false,
  }) async {
    try {
      final query = select(${FEATURE_SNAKE}UserRoles)
        ..where((t) {
          var condition = t.${FEATURE_ID_NAME}.equals(featureId);
          if (!includeDeleted) {
            condition = condition & t.isDeleted.equals(false);
          }
          return condition;
        })
        ..orderBy([
          (t) => OrderingTerm(expression: t.role, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt),
        ]);

      final roles = await query.get();
      return Success(roles);
    } catch (e) {
      return Failure(DataException('Failed to list feature members: $e'));
    }
  }

  @override
  Future<Result<List<FeatureUserRoleDetails>>> listUserFeatures({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      final query = select(${FEATURE_SNAKE}UserRoles)
        ..where((t) {
          var condition = t.userId.equals(userId);
          if (!includeDeleted) {
            condition = condition & t.isDeleted.equals(false);
          }
          return condition;
        })
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);

      final roles = await query.get();
      return Success(roles);
    } catch (e) {
      return Failure(DataException('Failed to list user features: $e'));
    }
  }

  @override
  Future<Result<FeatureUserRoleDetails>> updateRole(
    FeatureUserRoleUpdate data,
  ) async {
    try {
      if (!data.hasChanges) {
        return Failure(DataException('No changes to update'));
      }

      final companion = ${FEATURE_PASCAL}UserRolesCompanion(
        id: Value(data.id),
        role: data.role != null ? Value(data.role!) : const Value.absent(),
        isActive:
            data.isActive != null ? Value(data.isActive!) : const Value.absent(),
        isDeleted: data.isDeleted != null
            ? Value(data.isDeleted!)
            : const Value.absent(),
      );

      final updated = await (update(${FEATURE_SNAKE}UserRoles)
            ..where((t) => t.id.equals(data.id)))
          .write(companion);

      if (updated == 0) {
        return Failure(DataException('Role not found'));
      }

      final role = await (select(${FEATURE_SNAKE}UserRoles)
            ..where((t) => t.id.equals(data.id)))
          .getSingle();

      return Success(role);
    } catch (e) {
      return Failure(DataException('Failed to update role: $e'));
    }
  }

  @override
  Future<Result<bool>> hasRole({
    required String userId,
    required String featureId,
    required FeatureUserRole minRole,
  }) async {
    try {
      final result = await getUserRole(
        userId: userId,
        featureId: featureId,
      );

      return result.when(
        success: (details) {
          if (details == null) return const Success(false);
          return Success(details.role >= minRole);
        },
        failure: Failure.new,
      );
    } catch (e) {
      return Failure(DataException('Failed to check role: $e'));
    }
  }
}
EOF_TEMPLATE

# Substituir placeholders
sed -i "s/\${FEATURE_SNAKE}/$FEATURE_SNAKE/g" "$REPO_FILE"
sed -i "s/\${FEATURE_PASCAL}/$FEATURE_PASCAL/g" "$REPO_FILE"
sed -i "s/\${FEATURE_ID_NAME}/$FEATURE_ID_NAME/g" "$REPO_FILE"
sed -i "s/\${FEATURE_NAME}/$FEATURE_NAME/g" "$REPO_FILE"

success "Repository gerado!"
info "Arquivo: $REPO_FILE"
echo ""

# ============================================================================
# 3. Gerar Service
# ============================================================================

SERVICE_FILE="$SERVER_PATH/lib/src/services/${FEATURE_SNAKE}_user_role_service.dart"
ensure_dir "$(dirname "$SERVICE_FILE")"

progress "Gerando ${FEATURE_PASCAL}UserRoleService..."

cat > "$SERVICE_FILE" <<'EOF_SERVICE'
import 'package:core_shared/core_shared.dart' show Result, Unit;
import 'package:auth_shared/auth_shared.dart';
import '../repositories/${FEATURE_SNAKE}_user_role_repository.dart';

/// Serviço de gerenciamento de papéis de usuários em ${FEATURE_NAME}.
///
/// Fornece lógica de negócio para operações de FeatureUserRole.
class ${FEATURE_PASCAL}UserRoleService {
  final ${FEATURE_PASCAL}UserRoleRepository _repository;

  ${FEATURE_PASCAL}UserRoleService(this._repository);

  /// Concede um papel a um usuário em um ${FEATURE_NAME}.
  Future<Result<FeatureUserRoleDetails>> grantRole({
    required String userId,
    required String ${FEATURE_ID_NAME},
    required FeatureUserRole role,
  }) async {
    final create = FeatureUserRoleCreate(
      userId: userId,
      featureId: ${FEATURE_ID_NAME},
      role: role,
    );

    return _repository.grant(create);
  }

  /// Revoga o papel de um usuário em um ${FEATURE_NAME}.
  Future<Result<Unit>> revokeRole({
    required String userId,
    required String ${FEATURE_ID_NAME},
  }) async {
    return _repository.revoke(
      userId: userId,
      featureId: ${FEATURE_ID_NAME},
    );
  }

  /// Obtém o papel de um usuário em um ${FEATURE_NAME}.
  Future<Result<FeatureUserRoleDetails?>> getUserRole({
    required String userId,
    required String ${FEATURE_ID_NAME},
  }) async {
    return _repository.getUserRole(
      userId: userId,
      featureId: ${FEATURE_ID_NAME},
    );
  }

  /// Lista todos os membros de um ${FEATURE_NAME}.
  Future<Result<List<FeatureUserRoleDetails>>> listMembers({
    required String ${FEATURE_ID_NAME},
    bool includeDeleted = false,
  }) async {
    return _repository.listFeatureMembers(
      featureId: ${FEATURE_ID_NAME},
      includeDeleted: includeDeleted,
    );
  }

  /// Lista todos os ${FEATURE_NAME}s onde o usuário tem um papel.
  Future<Result<List<FeatureUserRoleDetails>>> listUserFeatures({
    required String userId,
    bool includeDeleted = false,
  }) async {
    return _repository.listUserFeatures(
      userId: userId,
      includeDeleted: includeDeleted,
    );
  }

  /// Atualiza o papel de um usuário.
  Future<Result<FeatureUserRoleDetails>> updateRole({
    required String id,
    FeatureUserRole? role,
    bool? isActive,
  }) async {
    final update = FeatureUserRoleUpdate(
      id: id,
      role: role,
      isActive: isActive,
    );

    return _repository.updateRole(update);
  }

  /// Verifica se um usuário tem um papel mínimo requerido.
  Future<Result<bool>> hasRole({
    required String userId,
    required String ${FEATURE_ID_NAME},
    required FeatureUserRole minRole,
  }) async {
    return _repository.hasRole(
      userId: userId,
      featureId: ${FEATURE_ID_NAME},
      minRole: minRole,
    );
  }

  /// Verifica se um usuário pode gerenciar membros.
  Future<Result<bool>> canManageMembers({
    required String userId,
    required String ${FEATURE_ID_NAME},
  }) async {
    return hasRole(
      userId: userId,
      ${FEATURE_ID_NAME}: ${FEATURE_ID_NAME},
      minRole: FeatureUserRole.manager,
    );
  }

  /// Verifica se um usuário é admin ou owner.
  Future<Result<bool>> isAdminOrOwner({
    required String userId,
    required String ${FEATURE_ID_NAME},
  }) async {
    return hasRole(
      userId: userId,
      ${FEATURE_ID_NAME}: ${FEATURE_ID_NAME},
      minRole: FeatureUserRole.admin,
    );
  }
}
EOF_SERVICE

# Substituir placeholders
sed -i "s/\${FEATURE_SNAKE}/$FEATURE_SNAKE/g" "$SERVICE_FILE"
sed -i "s/\${FEATURE_PASCAL}/$FEATURE_PASCAL/g" "$SERVICE_FILE"
sed -i "s/\${FEATURE_ID_NAME}/$FEATURE_ID_NAME/g" "$SERVICE_FILE"
sed -i "s/\${FEATURE_NAME}/$FEATURE_NAME/g" "$SERVICE_FILE"

success "Service gerado!"
info "Arquivo: $SERVICE_FILE"
echo ""

# ============================================================================
# Resumo
# ============================================================================

success "✨ Geração completa!"
echo ""
info "Arquivos gerados:"
info "  1. $TABLE_FILE"
info "  2. $REPO_FILE"
info "  3. $SERVICE_FILE"
echo ""
info "⚠️  Próximos passos:"
info "  1. Adicionar a tabela ao database file:"
info "     ${SERVER_PATH}/lib/src/database/${FEATURE_SNAKE}_database.dart"
info ""
info "  2. Executar build_runner:"
info "     cd $SERVER_PATH"
info "     dart run build_runner build --delete-conflicting-outputs"
info ""
info "  3. Registrar repository e service no dependency injection"
info ""
info "  4. (Opcional) Criar routes para endpoints HTTP"
info ""
info "📚 Consulte FEATURE_USER_ROLE_GUIDE.md para mais detalhes"
