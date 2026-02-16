import '../../domain/dtos/tag_update.dart';

/// Model for TagUpdate serialization/deserialization.
///
/// Responsible for converting TagUpdate DTOs to/from JSON.
class TagUpdateModel {
  final TagUpdate dto;

  /// Creates a TagUpdateModel wrapping a DTO.
  const TagUpdateModel(this.dto);

  /// Deserializes from JSON.
  factory TagUpdateModel.fromJson(Map<String, dynamic> json) {
    return TagUpdateModel(
      TagUpdate(
        id: json['id'] as String,
        name: json['name'] as String?,
        description: json['description'] as String?,
        color: json['color'] as String?,
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
      ),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'id': dto.id};

    // Only include non-null fields for partial updates
    if (dto.name != null) json['name'] = dto.name;
    if (dto.description != null) json['description'] = dto.description;
    if (dto.color != null) json['color'] = dto.color;
    if (dto.isActive != null) json['is_active'] = dto.isActive;
    if (dto.isDeleted != null) json['is_deleted'] = dto.isDeleted;

    return json;
  }

  /// Converts to domain DTO.
  TagUpdate toDomain() => dto;

  /// Creates from domain DTO.
  factory TagUpdateModel.fromDomain(TagUpdate update) => TagUpdateModel(update);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagUpdateModel &&
          runtimeType == other.runtimeType &&
          dto == other.dto;

  @override
  int get hashCode => dto.hashCode;

  @override
  String toString() => 'TagUpdateModel(${dto.toString()})';
}
