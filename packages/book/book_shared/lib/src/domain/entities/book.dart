/// Entidade de domínio representando Book.
///
/// Entidades são objetos de domínio puros que contêm apenas lógica de negócio.
/// - NÃO devem ter campo 'id' (é responsabilidade de BookDetails)
/// - NÃO devem ter serialização JSON (é responsabilidade de BookModel)
/// - NÃO devem ter dependências externas
class Book {
  final String title;
  final String isbn;
  final int publishYear;
  const Book({
    required this.title,
    required this.isbn,
    required this.publishYear  });

  /// Cria uma cópia da entidade com os campos especificados atualizados
  Book copyWith({
    String? title,
    String? isbn,
    int? publishYear,
  }) {
    return Book(
      title: title ?? this.title,
      isbn: isbn ?? this.isbn,
      publishYear: publishYear ?? this.publishYear,
    );
  }

  @override
  bool operator ==(Object other) =>
        identical(this, other) ||
        other is Book &&
            runtimeType == other.runtimeType &&
        title == other.title &&
            isbn == other.isbn &&
            publishYear == other.publishYear;

  @override
  int get hashCode =>
        title.hashCode ^
        isbn.hashCode ^
        publishYear.hashCode;

  @override
  String toString() => 'Book(title: $title, isbn: $isbn, publishYear: $publishYear)';
}
