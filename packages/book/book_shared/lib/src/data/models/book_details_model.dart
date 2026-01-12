import '../../domain/entities/book_details.dart';

/// Model para serialização JSON de BookDetails.
///
/// - Contém campo 'entity' do tipo BookDetails
/// - Serialização JSON MANUAL (sem @JsonSerializable)
/// - Métodos: fromJson, toJson, fromDomain, toDomain
class BookDetailsModel {
  final BookDetails entity;

  BookDetailsModel(this.entity);

  /// Converte JSON para Model
  factory BookDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookDetailsModel(
      BookDetails(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        title: json['title'] as String,
        isbn: json['isbn'] as String,
        publishYear: json['publishYear'] as int,
      ),
    );
  }

  /// Converte Model para JSON
  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'is_deleted': entity.isDeleted,
        'is_active': entity.isActive,
        'created_at': entity.createdAt.toIso8601String(),
        'updated_at': entity.updatedAt.toIso8601String(),
        'title': entity.title,
        'isbn': entity.isbn,
        'publishYear': entity.publishYear,
      };

  /// Converte Model para Domain
  BookDetails toDomain() => entity;

  /// Converte Domain para Model
  factory BookDetailsModel.fromDomain(BookDetails details) =>
      BookDetailsModel(details);
}
