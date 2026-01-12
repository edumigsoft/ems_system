import '../../domain/dtos/book_create.dart';
import 'package:core_shared/core_shared.dart';
import '../models/book_create_model.dart';

/// Conversor para BookCreate ↔ BookCreateModel.
///
/// Centraliza lógica de conversão entre Model e Domain.
class BookCreateConverter implements ModelConverter<BookCreateModel, BookCreate> {
  
  const BookCreateConverter();
  
  @override
  BookCreate toDomain(BookCreateModel model) => model.toDomain();
  
  @override
  BookCreateModel fromDomain(BookCreate domain) => 
      BookCreateModel.fromDomain(domain);
}
