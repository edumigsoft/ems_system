import '../../domain/dtos/book_update.dart';

/// Model para serialização JSON de BookUpdate.
class BookUpdateModel {
  final BookUpdate data;

  BookUpdateModel(this.data);

  factory BookUpdateModel.fromJson(Map<String, dynamic> json) {
    return BookUpdateModel(
      BookUpdate(
        id: json['id'] as String,
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
        title: json['title'] as String,
        isbn: json['isbn'] as String,
        publishYear: json['publishYear'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': data.id,
        if (data.isActive != null) 'is_active': data.isActive,
        if (data.isDeleted != null) 'is_deleted': data.isDeleted,
        'title': data.title,
        'isbn': data.isbn,
        'publishYear': data.publishYear,
      };

  BookUpdate toDomain() => data;

  factory BookUpdateModel.fromDomain(BookUpdate dto) =>
      BookUpdateModel(dto);
}
