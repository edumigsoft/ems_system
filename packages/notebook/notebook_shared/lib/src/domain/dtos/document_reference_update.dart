import '../enums/document_storage_type.dart';

/// DTO para atualização de DocumentReference
///
/// Contém [id] obrigatório e campos opcionais para atualização parcial.
/// Inclui [isActive] e [isDeleted] para controle de estado.
class DocumentReferenceUpdate {
  final String id; // Obrigatório - identifica qual registro atualizar

  // Campos de negócio opcionais
  final String? name;
  final String? path;
  final DocumentStorageType? storageType;
  final String? mimeType;
  final int? sizeBytes;
  final String? notebookId;

  // Campos de BaseDetails para controle
  final bool? isActive; // Permite ativar/desativar
  final bool? isDeleted; // Permite soft delete

  DocumentReferenceUpdate({
    required this.id,
    this.name,
    this.path,
    this.storageType,
    this.mimeType,
    this.sizeBytes,
    this.notebookId,
    this.isActive,
    this.isDeleted,
  });

  /// Verifica se há alguma mudança
  bool get hasChanges =>
      name != null ||
      path != null ||
      storageType != null ||
      mimeType != null ||
      sizeBytes != null ||
      notebookId != null ||
      isActive != null ||
      isDeleted != null;

  /// Verifica se está sendo desativado
  bool get isBeingDeactivated => isActive == false;

  /// Verifica se está sendo ativado
  bool get isBeingActivated => isActive == true;

  /// Verifica se está sendo deletado (soft delete)
  bool get isBeingDeleted => isDeleted == true;

  /// Verifica se está sendo restaurado
  bool get isBeingRestored => isDeleted == false;

  @override
  String toString() =>
      'DocumentReferenceUpdate(id: $id, hasChanges: $hasChanges)';
}
