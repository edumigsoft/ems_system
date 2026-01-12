import '../../domain/dtos/book_create.dart';

/// Model para serialização JSON de BookCreate.
class BookCreateModel {
  final BookCreate data;

  BookCreateModel(this.data);

  factory BookCreateModel.fromJson(Map<String, dynamic> json) {
    return BookCreateModel(
      BookCreate(
      title: json['title'] as String,
      isbn: json['isbn'] as String,
      publishYear: json['publishYear'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': data.title,
        'isbn': data.isbn,
        'publishYear': data.publishYear,
      };

  BookCreate toDomain() => data;

  factory BookCreateModel.fromDomain(BookCreate dto) =>
      BookCreateModel(dto);
}
