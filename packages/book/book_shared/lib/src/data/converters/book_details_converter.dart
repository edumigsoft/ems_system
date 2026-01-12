import '../../domain/entities/book_details.dart';
import 'package:core_shared/core_shared.dart';
import '../models/book_details_model.dart';

/// Conversor para BookDetails ↔ BookDetailsModel.
///
/// Centraliza lógica de conversão entre Model e Domain.
class BookDetailsConverter implements ModelConverter<BookDetailsModel, BookDetails> {
  
  const BookDetailsConverter();
  
  @override
  BookDetails toDomain(BookDetailsModel model) => model.toDomain();
  
  @override
  BookDetailsModel fromDomain(BookDetails domain) => 
      BookDetailsModel.fromDomain(domain);
}
