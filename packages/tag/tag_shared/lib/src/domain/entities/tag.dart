/// Tag domain entity.
///
/// Represents a tag in its purest form, containing only business logic fields.
/// This entity is completely agnostic of persistence concerns (no id, no audit fields).
class Tag {
  /// Tag name (required).
  final String name;

  /// Optional description of what this tag represents.
  final String? description;

  /// Optional hex color for UI display (e.g., '#FF5722').
  final String? color;

  /// Creates a Tag entity.
  const Tag({
    required this.name,
    this.description,
    this.color,
  });

  /// Creates a copy of this Tag with modified fields.
  Tag copyWith({
    String? name,
    String? description,
    String? color,
  }) {
    return Tag(
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          color == other.color;

  @override
  int get hashCode => Object.hash(name, description, color);

  @override
  String toString() =>
      'Tag(name: $name, description: $description, color: $color)';
}
