import '../../domain/dtos/notebook_create.dart';
import '../../domain/enums/notebook_type.dart';

/// Model for NotebookCreate serialization/deserialization.
///
/// Responsible for converting NotebookCreate to/from JSON.
/// This isolates serialization concerns from domain DTOs.
class NotebookCreateModel {
  final NotebookCreate dto;

  /// Creates a NotebookCreateModel wrapping a DTO.
  const NotebookCreateModel(this.dto);

  /// Deserializes from JSON.
  factory NotebookCreateModel.fromJson(Map<String, dynamic> json) {
    return NotebookCreateModel(
      NotebookCreate(
        title: json['title'] as String,
        content: json['content'] as String,
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
      ),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'title': dto.title,
    'content': dto.content,
    'project_id': dto.projectId,
    'parent_id': dto.parentId,
    'tags': dto.tags,
    'type': dto.type?.name,
    'reminder_date': dto.reminderDate?.toIso8601String(),
    'notify_on_reminder': dto.notifyOnReminder,
    'document_ids': dto.documentIds,
  };

  /// Converts to domain DTO.
  NotebookCreate toDomain() => dto;

  /// Creates from domain DTO.
  factory NotebookCreateModel.fromDomain(NotebookCreate create) =>
      NotebookCreateModel(create);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookCreateModel &&
          runtimeType == other.runtimeType &&
          dto == other.dto;

  @override
  int get hashCode => dto.hashCode;

  @override
  String toString() => 'NotebookCreateModel(${dto.toString()})';
}
