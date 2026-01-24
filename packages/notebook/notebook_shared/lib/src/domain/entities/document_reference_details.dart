import 'package:core_shared/core_shared.dart';

import '../enums/document_storage_type.dart';
import 'document_reference.dart';

/// EntityDetails para DocumentReference - Agregação completa com metadados de persistência
///
/// Implementa [BaseDetails] contendo todos os campos de [DriftTableMixinPostgres]
/// e compõe a entidade de domínio [DocumentReference] através do campo [data].
class DocumentReferenceDetails implements BaseDetails {
  // Campos do BaseDetails (alinhados com DriftTableMixinPostgres)
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt; // NOT NULL - tem default no DB
  @override
  final DateTime updatedAt; // NOT NULL - tem default no DB

  // Composição da Entity de negócio
  final DocumentReference data;

  // Campos adicionais de relacionamento
  final String? notebookId; // ID do notebook ao qual este documento pertence

  DocumentReferenceDetails({
    required this.id,
    this.isDeleted = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required String name,
    required String path,
    required DocumentStorageType storageType,
    String? mimeType,
    int? sizeBytes,
    this.notebookId,
  }) : data = DocumentReference(
          name: name,
          path: path,
          storageType: storageType,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
        );

  // Getters de conveniência para campos da Entity
  String get name => data.name;
  String get path => data.path;
  DocumentStorageType get storageType => data.storageType;
  String? get mimeType => data.mimeType;
  int? get sizeBytes => data.sizeBytes;

  // Acesso à lógica de negócio da Entity
  bool get isPdf => data.isPdf;
  bool get isImage => data.isImage;
  bool get isDocument => data.isDocument;
  bool get isOnServer => data.isOnServer;
  bool get isLocal => data.isLocal;
  bool get isExternalUrl => data.isExternalUrl;
  String get formattedSize => data.formattedSize;
  bool get isLargeFile => data.isLargeFile;
  String get displayName => data.displayName;

  /// Verifica se está vinculado a um notebook
  bool get hasNotebook => notebookId != null;

  /// Getter de conveniência para uploadedAt (alias para createdAt)
  /// Semanticamente, a data de upload é a data de criação do registro
  DateTime get uploadedAt => createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentReferenceDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DocumentReferenceDetails(id: $id, name: $name, type: $storageType)';
}
