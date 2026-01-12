// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from: DriftTableMixinPostgres
// Source: packages/core/core_server/lib/src/database/drift/drift_table_mixin.dart
// Generated at: 2025-12-31T14:15:30.403367

/// Contrato base para todas as entidades que possuem campos de persistência.
///
/// Esta interface define os campos padrão fornecidos pelo [DriftTableMixinPostgres]
/// em [core_server]. Qualquer mudança no mixin DEVE ser refletida aqui via
/// regeneração deste arquivo.
///
/// **IMPORTANTE:** Este arquivo é gerado automaticamente.
/// Para modificar, edite [DriftTableMixinPostgres] e execute:
/// ```bash
/// dart run tools/generate_base_details.dart
/// ```
///
/// Consulte: ADR-0006 (Sincronização BaseDetails ↔ DriftTableMixin)
abstract class BaseDetails {
  /// Identificador único (UUID gerado pelo banco)
  String get id;

  /// Data de criação (auto-gerada pelo banco)
  /// NOT NULL - possui default CURRENT_TIMESTAMP
  DateTime get createdAt;

  /// Data de última atualização (auto-atualizada pelo banco)
  /// NOT NULL - possui default CURRENT_TIMESTAMP
  DateTime get updatedAt;

  /// Flag de soft delete
  bool get isDeleted;

  /// Status de ativação
  bool get isActive;
}
