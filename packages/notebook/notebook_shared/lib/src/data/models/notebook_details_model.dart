import '../../domain/entities/notebook_details.dart';
import '../../domain/enums/notebook_type.dart';

/// Model for NotebookDetails serialization/deserialization.
///
/// Responsible for converting NotebookDetails to/from JSON.
/// This isolates serialization concerns from domain entities.
class NotebookDetailsModel {
  final NotebookDetails entity;

  /// Creates a NotebookDetailsModel wrapping an entity.
  const NotebookDetailsModel(this.entity);

  /// Deserializes from JSON.
  factory NotebookDetailsModel.fromJson(Map<String, dynamic> json) {
    return NotebookDetailsModel(
      NotebookDetails(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
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
        'id': entity.id,
        'is_deleted': entity.isDeleted,
        'is_active': entity.isActive,
        'created_at': entity.createdAt.toIso8601String(),
        'updated_at': entity.updatedAt.toIso8601String(),
        'title': entity.title,
        'content': entity.content,
        'project_id': entity.projectId,
        'parent_id': entity.parentId,
        'tags': entity.tags,
        'type': entity.type?.name,
        'reminder_date': entity.reminderDate?.toIso8601String(),
        'notify_on_reminder': entity.notifyOnReminder,
        'document_ids': entity.documentIds,
      };

  /// Converts to domain entity.
  NotebookDetails toDomain() => entity;

  /// Creates from domain entity.
  factory NotebookDetailsModel.fromDomain(NotebookDetails details) =>
      NotebookDetailsModel(details);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookDetailsModel &&
          runtimeType == other.runtimeType &&
          entity == other.entity;

  @override
  int get hashCode => entity.hashCode;

  @override
  String toString() => 'NotebookDetailsModel(${entity.toString()})';
}
