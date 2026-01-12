import '../../domain/dtos/book_update.dart';
import 'package:core_shared/core_shared.dart';
import '../models/book_update_model.dart';

/// Conversor para BookUpdate ↔ BookUpdateModel.
///
/// Centraliza lógica de conversão entre Model e Domain.
class BookUpdateConverter implements ModelConverter<BookUpdateModel, BookUpdate> {
  
  const BookUpdateConverter();
  
  @override
  BookUpdate toDomain(BookUpdateModel model) => model.toDomain();
  
  @override
  BookUpdateModel fromDomain(BookUpdate domain) => 
      BookUpdateModel.fromDomain(domain);
}
