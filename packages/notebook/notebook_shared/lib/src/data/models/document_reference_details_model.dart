import '../../domain/entities/document_reference_details.dart';
import '../../domain/enums/document_storage_type.dart';

/// Model for DocumentReferenceDetails serialization/deserialization.
///
/// Responsible for converting DocumentReferenceDetails to/from JSON.
/// This isolates serialization concerns from domain entities.
class DocumentReferenceDetailsModel {
  final DocumentReferenceDetails entity;

  /// Creates a DocumentReferenceDetailsModel wrapping an entity.
  const DocumentReferenceDetailsModel(this.entity);

  /// Deserializes from JSON.
  factory DocumentReferenceDetailsModel.fromJson(Map<String, dynamic> json) {
    return DocumentReferenceDetailsModel(
      DocumentReferenceDetails.create(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        name: json['name'] as String,
        path: json['path'] as String,
        storageType: DocumentStorageType.values.byName(
          json['storage_type'] as String,
        ),
        mimeType: json['mime_type'] as String?,
        sizeBytes: json['size_bytes'] as int?,
        notebookId: json['notebook_id'] as String?,
      ),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'id': entity.id,
    'is_deleted': entity.isDeleted,
    'is_active': entity.isActive,
    'created_at': entity.createdAt.toIso8601String(),
    'updated_at': entity.updatedAt.toIso8601String(),
    'name': entity.name,
    'path': entity.path,
    'storage_type': entity.storageType.name,
    'mime_type': entity.mimeType,
    'size_bytes': entity.sizeBytes,
    'notebook_id': entity.notebookId,
  };

  /// Converts to domain entity.
  DocumentReferenceDetails toDomain() => entity;

  /// Creates from domain entity.
  factory DocumentReferenceDetailsModel.fromDomain(
    DocumentReferenceDetails details,
  ) => DocumentReferenceDetailsModel(details);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentReferenceDetailsModel &&
          runtimeType == other.runtimeType &&
          entity == other.entity;

  @override
  int get hashCode => entity.hashCode;

  @override
  String toString() => 'DocumentReferenceDetailsModel(${entity.toString()})';
}
