import 'package:auth_shared/auth_shared.dart';
import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart';

import '../database/auth_database.dart';
import '../database/tables/project_user_role_table.dart';

part 'project_user_role_repository.g.dart';

/// Implementação do repositório de papéis de usuário em projetos.
///
/// Exemplo de implementação de FeatureUserRoleRepository.
/// Pode ser copiado e adaptado para outras features (finance, tasks, etc.).
@DriftAccessor(tables: [ProjectUserRoles])
class ProjectUserRoleRepository extends DatabaseAccessor<AuthDatabase>
    with _$ProjectUserRoleRepositoryMixin
    implements FeatureUserRoleRepository {
  ProjectUserRoleRepository(AuthDatabase db) : super(db);

  @override
  Future<Result<FeatureUserRoleDetails>> grant(
    FeatureUserRoleCreate data,
  ) async {
    try {
      if (!data.isValid) {
        return Failure(DataException('Invalid role data'));
      }

      await into(projectUserRoles).insertOnConflictUpdate(
        ProjectUserRolesCompanion(
          userId: Value(data.userId),
          projectId: Value(data.featureId),
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
        failure: (error) => Failure(error),
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
      final statement = update(projectUserRoles)
        ..where((t) => t.userId.equals(userId) & t.projectId.equals(featureId));

      await statement.write(
        const ProjectUserRolesCompanion(isDeleted: Value(true)),
      );

      return successOfUnit();
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
      final query = select(projectUserRoles)
        ..where(
          (t) =>
              t.userId.equals(userId) &
              t.projectId.equals(featureId) &
              t.isDeleted.equals(0),
        );

      final result = await query.getSingleOrNull();

      if (result == null) {
        return const Success(null);
      }

      final details = FeatureUserRoleDetails.create(
        id: result.id,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
        isDeleted: result.isDeleted != 0,
        isActive: result.isActive != 0,
        userId: result.userId,
        featureId: result.projectId,
        role: result.role,
      );

      return Success(details);
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
      final query = select(projectUserRoles)
        ..where((t) => t.projectId.equals(featureId));

      if (!includeDeleted) {
        query.where((t) => t.isDeleted.equals(0));
      }

      final results = await query.get();

      final details = results
          .map(
            (r) => FeatureUserRoleDetails.create(
              id: r.id,
              createdAt: r.createdAt,
              updatedAt: r.updatedAt,
              isDeleted: r.isDeleted != 0,
              isActive: r.isActive != 0,
              userId: r.userId,
              featureId: r.projectId,
              role: r.role,
            ),
          )
          .toList();

      return Success(details);
    } catch (e) {
      return Failure(DataException('Failed to list members: $e'));
    }
  }

  @override
  Future<Result<List<FeatureUserRoleDetails>>> listUserFeatures({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      final query = select(projectUserRoles)
        ..where((t) => t.userId.equals(userId));

      if (!includeDeleted) {
        query.where((t) => t.isDeleted.equals(0));
      }

      final results = await query.get();

      final details = results
          .map(
            (r) => FeatureUserRoleDetails.create(
              id: r.id,
              createdAt: r.createdAt,
              updatedAt: r.updatedAt,
              isDeleted: r.isDeleted != 0,
              isActive: r.isActive != 0,
              userId: r.userId,
              featureId: r.projectId,
              role: r.role,
            ),
          )
          .toList();

      return Success(details);
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
        return Failure(DataException('No changes to apply'));
      }

      final statement = update(projectUserRoles)
        ..where((t) => t.id.equals(data.id));

      await statement.write(
        ProjectUserRolesCompanion(
          role: data.role != null ? Value(data.role!) : const Value.absent(),
          isActive: data.isActive != null
              ? Value(data.isActive!)
              : const Value.absent(),
          isDeleted: data.isDeleted != null
              ? Value(data.isDeleted!)
              : const Value.absent(),
        ),
      );

      final result = await (select(
        projectUserRoles,
      )..where((t) => t.id.equals(data.id))).getSingleOrNull();

      if (result == null) {
        return Failure(DataException('Role not found after update'));
      }

      final details = FeatureUserRoleDetails.create(
        id: result.id,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
        isDeleted: result.isDeleted != 0,
        isActive: result.isActive != 0,
        userId: result.userId,
        featureId: result.projectId,
        role: result.role,
      );

      return Success(details);
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
    final result = await getUserRole(userId: userId, featureId: featureId);

    return result.when(
      success: (details) {
        if (details == null) return const Success(false);
        return Success(details.role >= minRole);
      },
      failure: (error) => Failure(error),
    );
  }
}
