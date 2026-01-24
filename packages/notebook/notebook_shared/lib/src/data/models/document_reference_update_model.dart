import '../../domain/dtos/document_reference_update.dart';
import '../../domain/enums/document_storage_type.dart';

/// Model for DocumentReferenceUpdate serialization/deserialization.
///
/// Responsible for converting DocumentReferenceUpdate to/from JSON.
/// This isolates serialization concerns from domain DTOs.
class DocumentReferenceUpdateModel {
  final DocumentReferenceUpdate dto;

  /// Creates a DocumentReferenceUpdateModel wrapping a DTO.
  const DocumentReferenceUpdateModel(this.dto);

  /// Deserializes from JSON.
  factory DocumentReferenceUpdateModel.fromJson(Map<String, dynamic> json) {
    return DocumentReferenceUpdateModel(
      DocumentReferenceUpdate(
        id: json['id'] as String,
        name: json['name'] as String?,
        path: json['path'] as String?,
        storageType: json['storage_type'] != null
            ? DocumentStorageType.values.byName(json['storage_type'] as String)
            : null,
        mimeType: json['mime_type'] as String?,
        sizeBytes: json['size_bytes'] as int?,
        notebookId: json['notebook_id'] as String?,
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
      ),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'id': dto.id};

    // Only include non-null fields for partial updates
    if (dto.name != null) json['name'] = dto.name;
    if (dto.path != null) json['path'] = dto.path;
    if (dto.storageType != null) json['storage_type'] = dto.storageType!.name;
    if (dto.mimeType != null) json['mime_type'] = dto.mimeType;
    if (dto.sizeBytes != null) json['size_bytes'] = dto.sizeBytes;
    if (dto.notebookId != null) json['notebook_id'] = dto.notebookId;
    if (dto.isActive != null) json['is_active'] = dto.isActive;
    if (dto.isDeleted != null) json['is_deleted'] = dto.isDeleted;

    return json;
  }

  /// Converts to domain DTO.
  DocumentReferenceUpdate toDomain() => dto;

  /// Creates from domain DTO.
  factory DocumentReferenceUpdateModel.fromDomain(
    DocumentReferenceUpdate update,
  ) =>
      DocumentReferenceUpdateModel(update);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentReferenceUpdateModel &&
          runtimeType == other.runtimeType &&
          dto == other.dto;

  @override
  int get hashCode => dto.hashCode;

  @override
  String toString() => 'DocumentReferenceUpdateModel(${dto.toString()})';
}
