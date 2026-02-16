import '../../domain/dtos/document_reference_create.dart';
import '../../domain/enums/document_storage_type.dart';

/// Model for DocumentReferenceCreate serialization/deserialization.
///
/// Responsible for converting DocumentReferenceCreate to/from JSON.
/// This isolates serialization concerns from domain DTOs.
class DocumentReferenceCreateModel {
  final DocumentReferenceCreate dto;

  /// Creates a DocumentReferenceCreateModel wrapping a DTO.
  const DocumentReferenceCreateModel(this.dto);

  /// Deserializes from JSON.
  factory DocumentReferenceCreateModel.fromJson(Map<String, dynamic> json) {
    return DocumentReferenceCreateModel(
      DocumentReferenceCreate(
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
    'name': dto.name,
    'path': dto.path,
    'storage_type': dto.storageType.name,
    'mime_type': dto.mimeType,
    'size_bytes': dto.sizeBytes,
    'notebook_id': dto.notebookId,
  };

  /// Converts to domain DTO.
  DocumentReferenceCreate toDomain() => dto;

  /// Creates from domain DTO.
  factory DocumentReferenceCreateModel.fromDomain(
    DocumentReferenceCreate create,
  ) => DocumentReferenceCreateModel(create);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentReferenceCreateModel &&
          runtimeType == other.runtimeType &&
          dto == other.dto;

  @override
  int get hashCode => dto.hashCode;

  @override
  String toString() => 'DocumentReferenceCreateModel(${dto.toString()})';
}
