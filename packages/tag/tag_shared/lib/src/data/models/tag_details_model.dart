import '../../domain/entities/tag_details.dart';

/// Model for TagDetails serialization/deserialization.
///
/// Responsible for converting TagDetails to/from JSON.
/// This isolates serialization concerns from domain entities.
class TagDetailsModel {
  final TagDetails entity;

  /// Creates a TagDetailsModel wrapping an entity.
  const TagDetailsModel(this.entity);

  /// Deserializes from JSON.
  factory TagDetailsModel.fromJson(Map<String, dynamic> json) {
    return TagDetailsModel(
      TagDetails(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        name: json['name'] as String,
        description: json['description'] as String?,
        color: json['color'] as String?,
        usageCount: json['usage_count'] as int? ?? 0,
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
        'description': entity.description,
        'color': entity.color,
        'usage_count': entity.usageCount,
      };

  /// Converts to domain entity.
  TagDetails toDomain() => entity;

  /// Creates from domain entity.
  factory TagDetailsModel.fromDomain(TagDetails details) =>
      TagDetailsModel(details);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagDetailsModel &&
          runtimeType == other.runtimeType &&
          entity == other.entity;

  @override
  int get hashCode => entity.hashCode;

  @override
  String toString() => 'TagDetailsModel(${entity.toString()})';
}
