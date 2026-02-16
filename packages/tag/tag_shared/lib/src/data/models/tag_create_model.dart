import '../../domain/dtos/tag_create.dart';

/// Model for TagCreate serialization/deserialization.
///
/// Responsible for converting TagCreate DTOs to/from JSON.
class TagCreateModel {
  final TagCreate dto;

  /// Creates a TagCreateModel wrapping a DTO.
  const TagCreateModel(this.dto);

  /// Deserializes from JSON.
  factory TagCreateModel.fromJson(Map<String, dynamic> json) {
    return TagCreateModel(
      TagCreate(
        name: json['name'] as String,
        description: json['description'] as String?,
        color: json['color'] as String?,
      ),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'name': dto.name,
    'description': dto.description,
    'color': dto.color,
  };

  /// Converts to domain DTO.
  TagCreate toDomain() => dto;

  /// Creates from domain DTO.
  factory TagCreateModel.fromDomain(TagCreate create) => TagCreateModel(create);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagCreateModel &&
          runtimeType == other.runtimeType &&
          dto == other.dto;

  @override
  int get hashCode => dto.hashCode;

  @override
  String toString() => 'TagCreateModel(${dto.toString()})';
}
