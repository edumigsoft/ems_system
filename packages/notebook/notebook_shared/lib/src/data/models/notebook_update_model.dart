import '../../domain/dtos/notebook_update.dart';
import '../../domain/enums/notebook_type.dart';

/// Model for NotebookUpdate serialization/deserialization.
///
/// Responsible for converting NotebookUpdate to/from JSON.
/// This isolates serialization concerns from domain DTOs.
class NotebookUpdateModel {
  final NotebookUpdate dto;

  /// Creates a NotebookUpdateModel wrapping a DTO.
  const NotebookUpdateModel(this.dto);

  /// Deserializes from JSON.
  factory NotebookUpdateModel.fromJson(Map<String, dynamic> json) {
    return NotebookUpdateModel(
      NotebookUpdate(
        id: json['id'] as String,
        title: json['title'] as String?,
        content: json['content'] as String?,
        projectId: json['project_id'] as String?,
        parentId: json['parent_id'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
        type: json['type'] != null
            ? NotebookType.values.byName(json['type'] as String)
            : null,
        reminderDate: json['reminder_date'] != null
            ? DateTime.parse(json['reminder_date'] as String)
            : null,
        notifyOnReminder: json['notify_on_reminder'] as bool?,
        documentIds: (json['document_ids'] as List<dynamic>?)?.cast<String>(),
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
      ),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'id': dto.id};

    // Only include non-null fields for partial updates
    if (dto.title != null) json['title'] = dto.title;
    if (dto.content != null) json['content'] = dto.content;
    if (dto.projectId != null) json['project_id'] = dto.projectId;
    if (dto.parentId != null) json['parent_id'] = dto.parentId;
    if (dto.tags != null) json['tags'] = dto.tags;
    if (dto.type != null) json['type'] = dto.type!.name;
    if (dto.reminderDate != null) {
      json['reminder_date'] = dto.reminderDate!.toIso8601String();
    }
    if (dto.notifyOnReminder != null) {
      json['notify_on_reminder'] = dto.notifyOnReminder;
    }
    if (dto.documentIds != null) json['document_ids'] = dto.documentIds;
    if (dto.isActive != null) json['is_active'] = dto.isActive;
    if (dto.isDeleted != null) json['is_deleted'] = dto.isDeleted;

    return json;
  }

  /// Converts to domain DTO.
  NotebookUpdate toDomain() => dto;

  /// Creates from domain DTO.
  factory NotebookUpdateModel.fromDomain(NotebookUpdate update) =>
      NotebookUpdateModel(update);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookUpdateModel &&
          runtimeType == other.runtimeType &&
          dto == other.dto;

  @override
  int get hashCode => dto.hashCode;

  @override
  String toString() => 'NotebookUpdateModel(${dto.toString()})';
}
