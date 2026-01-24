/// DTO for updating an existing tag.
///
/// Contains the id (required) and optional fields for partial updates.
/// Includes control fields (isActive, isDeleted) for status management.
///
/// IMPORTANT:
/// - createdAt is NOT included (immutable - never changes)
/// - updatedAt is NOT included (auto-managed by database)
class TagUpdate {
  /// Tag ID to update (required).
  final String id;

  /// New name (optional).
  final String? name;

  /// New description (optional).
  final String? description;

  /// New color (optional).
  final String? color;

  /// Active status (optional) - for enable/disable operations.
  final bool? isActive;

  /// Deleted status (optional) - for soft delete operations.
  final bool? isDeleted;

  /// Creates a TagUpdate DTO.
  const TagUpdate({
    required this.id,
    this.name,
    this.description,
    this.color,
    this.isActive,
    this.isDeleted,
  });

  /// Whether this update contains any changes.
  bool get hasChanges =>
      name != null ||
      description != null ||
      color != null ||
      isActive != null ||
      isDeleted != null;

  /// Business validation.
  bool get isValid => id.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagUpdate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          color == other.color &&
          isActive == other.isActive &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode => Object.hash(id, name, description, color, isActive, isDeleted);

  @override
  String toString() => 'TagUpdate(id: $id, hasChanges: $hasChanges)';
}
